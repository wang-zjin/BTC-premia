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

def get_btc_prices_2015_2023():

    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    qdat = quandl.get('BCHAIN/MKPRU', start_date = '2015-01-01', end_date = '2023-12-31')
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

def get_btc_prices_varying_range(start_date='2015-01-01', end_date='2023-12-31'):

    # 设置Quandl的API密钥
    api_key = '51s_oiWJMf5t6tiUtG8F'
    quandl.ApiConfig.api_key = api_key

    # 从Quandl获取比特币价格数据
    qdat = quandl.get('BCHAIN/MKPRU', start_date = start_date, end_date = end_date)
    # 重置数据索引
    qdat.reset_index(inplace = True)
    # 重命名列名
    qdat = qdat.rename(columns = {'Value': 'Adj.Close'})
    # 返回处理后的数据
    return qdat