import quandl

def get_btc_prices():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2018-01-01', end_date = '2021-04-10')
    qdat.reset_index(inplace = True)
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    return qdat

def get_btc_prices_new():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2018-01-01', end_date = '2022-04-10')
    qdat.reset_index(inplace = True)
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    return qdat

def get_btc_prices_2022():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2018-01-01', end_date = '2022-12-31')
    qdat.reset_index(inplace = True)
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    return qdat

def get_btc_prices_2015_2022():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2015-01-01', end_date = '2022-12-31')
    qdat.reset_index(inplace = True)
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    return qdat

def get_btc_prices_2015_20230930():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2015-01-01', end_date = '2023-09-30')
    qdat.reset_index(inplace = True)
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    return qdat
