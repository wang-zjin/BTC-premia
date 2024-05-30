import platform
plat = platform.system()
import locale
if plat == 'Darwin':
    print('Using Macos Locale')
    locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')
else:
    locale.setlocale(locale.LC_ALL, 'en_US.utf8')
import datetime
import pandas as pd
import numpy as np


import rpy2.robjects.packages as rpackages
from rpy2 import robjects

"""
from Q_Rookley.src.helpers import save_dict, load_dict
from Q_Rookley.src.brc import BRC
from Q_Rookley.src.strategies import IronCondor
from Q_Rookley.src.quandl_data import get_btc_prices_2015_2022
"""

"""class Rookley_Q_estimate_by_date(object):
    def __init__(self, date):
        self.date = date
        self.df = pd.read_csv('data/processed/20172023_processed.csv')
        self.interest_rate_data = pd.read_csv('data/IR_daily.csv')
        self.interest_rate_data = self.interest_rate_data.rename(columns={'index': 'date','DTB3': 'interest_rate'})
"""        




def filter_sub(_df,  mindate, maxdate, tau):
    # Subset

    # Only calls, tau in [0, 0.25] and fix one day (bc looking at intra day here)
    # (_df['is_call'] == 1) & --> Dont need to filter for calls because that happens in the R script
    # Also need to consider put-call parity there
    sub = _df[(_df['date'] >= mindate) & (_df['date'] <= maxdate) & (_df['moneyness'] >= 0.5) & (_df['moneyness'] < 2) &(_df['mark_iv'] > 0)]# &

    if tau > 0:
        sub = sub[sub['tau'] == tau]

    nrows = sub.shape[0]
    if nrows == 0:
        raise(ValueError('Sub is empty'))

    sub['moneyness'] = round(sub['moneyness'], 3)
    sub['underlying_price'] = round(sub['underlying_price'], 2)

    sub = sub.drop_duplicates()
    
    print(sub.describe())

    if nrows > 50000:
        print('large df, subsetting')
        sub = sub.sample(10000)
        print(sub.describe())

    return sub

def prepare_confidence_band_data(df):

    """
    # Mapping Table for Input

    # Column ... X
    # 1 - date
    # 2 - IV
    # 3 - 1 for Call, 0 for Put
    # 4 - Tau 
    # 5 - Strike
    # 6 - option price
    # 7 - Spot
    # 8 - Interest Rate
    # 9 - Moneyness: Strike/Spot
    """
    b = df[['date', 'mark_iv', 'putcall', 'tau', 'K', 'underlying_price', 'interest_rate', 'moneyness', 'instrument_price']]
    b['placeholder'] = 0
    b = b.reset_index(drop=True)
    b['forward'] = 1

    # Reorder
    df_c = b[['date', 'mark_iv', 'putcall', 'tau', 'K', 'instrument_price', 'underlying_price', 'interest_rate', 'moneyness']]

    fname = str('Q_Rookley/') + str('temporal') + str('.csv')
    df_c.to_csv(fname, index = False)
    return fname

def bootstrap(conf_fname, phys_fname, rdate, r, out_dir, bw, lower, upper):
                            
    try:
        # MAKE SURE TO USE DIFFERENT 2ND INPUT FOR SP500!!
        moneyness, spd, epk, epk_lo, epk_up, logret, spd_logret, epk_logret, epk_logret_lo, epk_logret_up, epk_BS, tau, volas, spd_lo, spd_up, cdf_m, cdf_ret= r.bootstrap_epk(robjects.StrVector([conf_fname]), 
                                    robjects.StrVector([phys_fname]),
                                    robjects.StrVector(rdate),
                                    robjects.StrVector([out_dir]),
                                    robjects.FloatVector([bw]),
                                    robjects.FloatVector([lower]),
                                    robjects.FloatVector([upper])
                                    )
        # Can recover PD here as SPD/EPK
        spd_df = pd.DataFrame({'m': moneyness,
                            'spdy': spd,
                            'spdy_up': spd_up,
                            'spdy_dn': spd_lo,
                            'epk': epk,
                            'ret': logret,
                            'spd_ret': spd_logret,
                            'cb_ret_up': epk_logret_up,
                            'cb_ret_dn': epk_logret_lo,
                            'epk_ret': epk_logret,
                            'volatility': volas,
                            'epk_up': epk_up,
                            'epk_dn': epk_lo,
                            'cdf_m': cdf_m,
                            'cdf_ret': cdf_ret})

        return spd_df
        
    except Exception as e:
        print('exception: ', e)
            
# Initiate R Objects
base = rpackages.importr("base") 
r = robjects.r
r.source('Q_Rookley/src/Q_Rookley_main.R')

bw_range = np.array([0.3])
r_bandwidth = bw_range[0]


df = pd.read_csv('data/processed/20172022_processed_1_3_4.csv')
interest_rate_data = pd.read_csv('data/interest_rate/IR_daily.csv')
interest_rate_data = interest_rate_data.rename(columns={'index': 'date','DTB3': 'interest_rate'})


def estimate_Rookley_Q(date):
    df1=df[df['date']==date]
    taus=df1['tau'].unique()

    # Initialize the error list for the current tau
    error_i = []
    for i0, tau in enumerate(taus):
        df2 = df1[df1['tau']==tau]

        curr_day = datetime.datetime.strptime(date,'%Y-%m-%d')
        curr_day_starttime = curr_day.replace(hour = 0, minute = 0, second = 0, microsecond = 0)
        curr_day_endtime = curr_day.replace(hour = 23, minute = 59, second = 59, microsecond = 0)
        print(curr_day)

        # If IR is time varying, then use following line:
        # df3 = pd.merge(df2, interest_rate_data, on='date', how='left')
        df3 = df2

        df3['interest_rate'] = 0
        df3['days_to_maturity'] = df3['tau']
        df3['tau'] = df3['tau']/365
        df3['underlying_price'] = df3['BTC_price']
        df3['instrument_price'] = df3['option_price']
        df3.loc[df3['putcall'] == 'C', 'putcall'] = 1
        df3.loc[df3['putcall'] == 'P', 'putcall'] = 0
        """df3['putcall'][df3['putcall']=='C']=1
        df3['putcall'][df3['putcall']=='P']=0"""

        df_1 = df3[['date','BTC_price', 'K', 'interest_rate', 'tau', 'putcall', 'IV',  'moneyness',
                    'days_to_maturity',  'underlying_price', 'instrument_price']]
        df_1['mark_iv']=df_1['IV']/100

        conf_fname = prepare_confidence_band_data(df_1)

        rdate = base.as_Date(curr_day.strftime('%Y-%m-%d'))
        current_date = base.format(rdate, '%Y-%m-%d')

        output_folder = 'Q_Rookley/Results/Rookley_Q_CB_1722_' + str(curr_day_starttime.__format__('%Y-%m-%d')) + '_IR0/'

        spd_btc = bootstrap(conf_fname, 'data/BTC_USD_Quandl_2011_2023.csv', current_date, r,
                            output_folder, r_bandwidth, df_1['moneyness'].min(), df_1['moneyness'].max())

        try :

            spd_btc.to_csv(output_folder + 'btc_q_ttm_'  + str(tau) +'_bw_' + str(r_bandwidth) +  '.csv')


        except Exception as e:
            # Append the index i0 to error_i list when an exception occurs
            error_i.append(i0)
            print(e)


# Vary date from 2017-07-01 to 2022-12-17 
"""dates_range = pd.date_range(start='2017-07-01', end='2022-12-17', freq='D')"""
dates_range = pd.date_range(start='2017-07-01', end='2022-12-17', freq='D')
dates_range = dates_range.strftime('%Y-%m-%d')
for date in dates_range:
    print(date)
    estimate_Rookley_Q(date)
