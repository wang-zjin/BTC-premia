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

