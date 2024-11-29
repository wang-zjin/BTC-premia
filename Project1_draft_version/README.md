# Risk Premia in Bitcoin Market

## 1. Summary Statistics:

- Codes: Summary_stats.m
- Output: 
	- Table 1: Summary statistics of BTC options
	- Table A2: Transactions of BTC options [in %]
	- Table A3: Summary statistics of BTC option quantity [in %]
	- Table A4: Summary statistics of BTC options volume [in %]

## 2. IV Estimation:

- Pre-smoothing: 
	- Locally Polynomial Regression: Q_Rookley folder
- Interpolation: 
	- SVI: IV folder

## 3. RND Estimation:

- RND from pre-smoothed IV: 
    - Pre-smoothing step generates RND based on pre-smoothed IV by BS formula.
	- Method: Transform IV curves to call option prices space by BS formula and generate RND by 2nd-order derivative
	- Codes: Q_Rookley folder
- RND from interpolated IV: IV folder
    - Method: Transform IV curves to call option prices space by BS formula and generate RND by 2nd-order derivative
	- Codes: Q_SVI folder

## 4. RND Tail Estimation:

- Codes: Q_tail_fit.m
- Output: 
	- Q densities in Q_Tail_Fit folder
