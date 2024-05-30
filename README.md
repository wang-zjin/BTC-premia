# BTC premia
 We examine the risk premia of Bitcoin and compare with tradittional equity. Moreover we explore different regimes based on nonparametric methods and display different state behaviours.

```yaml

Abstract: We adopt options and realized returns to analyze risk premia in the Bitcoin market. By decomposing the index risk premium into different parts of the return space, we find that negative returns between -60\% and -20\% explain one-third of the total Bitcoin equity premium (EP). This is not only in contrast to results for the S\&P 500 market, for which moderately negative returns explain 70\% of the EP (\cite{Beason2022-ht}), but also challenges conventional macro-finance models based on habit, disasters, and long-run risk explanations. 
By clustering data as a function of risk-neutral variance, we identify that risk premia vary over time directly depending on market conditions.
During low-volatility market states, investors are mainly concerned with variance risk. Out-of-the-money options (both puts and calls) are used for insurance purposes, and the pricing kernel is steep and U-shaped. During high-volatility states, investors are primarily concerned with downside risk.

Author: 'Caio Almeida', 'Maria Grith', 'Ratmir Miftachov', 'Zijin Wang'

Keywords: 'Risk Premium', 'Equity Premium', 'Variance Risk Premium', 'Pricing Kernel', 'Nonparametric Statistics', 'Cryptocurrency', 'Bitcoin', 'Option Returns', 'Clustering'

```

# BTC risk premium codes framework

## Data cleaning

### Scrab raw data and transform to csv

### Merge data from different source and time span

### Data cleaning

## Summary statistics

### Option transaction, quantity, volume

### IV, moneyness, tau

### BTC daily prices, returns

## Q density estimation

### Outline:

Direct estimation + Interpolation

- Rookley Q

	- IV by Local polynomial regression

		- Q density

- SVI Q

	- IV by SVI interpolation

		- Q density

## Clustering

### [x] Multivariate Q clustering

- CLR

### [ ] Univeriate Q clustering

## P density estimation

### Full sample rescale

- Full sample span:

2011-2022, 2014-2022 or 2015-2022

- Rescale: 

Non-rescale, Mean-only rescale, Variance-only rescale or Mean-and-variance rescale

### Estimation methods

- [x] Histogram

- [ ] KDE

## BVIX

### Input: orderbook option

### Output: one timeseries for each tau

## Risk premium

### BP

- mu_P - mu_Q

	- Q: density or 0

	- P: sample or density moment

- BP contribution

	- DCA

	- SCA

### VRP

- Var_P - Var_Q

	- Q: density or BVIX

	- P: sample or density moment

## Option return

### Simple hold-until-maturity returns

### Delta-hedge returns

