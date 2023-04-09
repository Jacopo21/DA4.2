# DA4.2
The database was downloaded from the WorldBank website and documents the relationship between Co2 emissions, measured in kt) and GDP per capita (constant 2017 international $). In addition, it has been taken into account the population growth across the years of all countries. The numeric variables consist of time, GDP per capita, population, and CO2 emissions, while the string variables comprise the country name and country code.
The subjects chosen were European and Central Asian with a high level of income. The time horizon extended from 1992 until the most recent year, 2019. Subsequently, geographically and demographically smaller states with a lack of data, such as the islands, have been eliminated. Subsequently, Andorra, San Marino, Liechtenstein and Greenland were eliminated as essential data on Co2 and GDP emissions were missing. 
In conclusion, the final database contained 28 nations. Defined the database I proceeded to create the related new variables including the logarithm of CO2 emissions and GDP of the countries, for analyzing logarithmic differences.

Analysis of models:
Cross-section OLS for the year 2005: 
A log-log regression was made.
The coefficient for ln GDP per capita is 0.596. A 1% increase in ln GDP per capita is associated with a 0.59% increase in ln Co2 emissions, holding all other variables constant.
The intercept (or constant) is -10.45, which is the average value of ln Co2 when ln GDP per capita is zero. 
More precisely, the average emission, across all countries, of co2 per capita is 0.0000149 kt in 2005. These findings are statistically significant as indicated by the p-value, and the 95% confidence interval not containing 0.
Cross-section OLS for a year of your choice:
The coefficient for ln GDP per capita is 0.499. Specifically, a 1% increase in ln GDP per capita is associated with a 0.499% increase in ln Co2 emissions, holding all other variables constant.
The intercept (or constant) is -10.18909, which is the predicted value of ln_co2 when ln GDP per capita is zero. More precisely, the average emission, across all countries, of co2 per capita is 0.0000276 kt in 2019. These findings are statistically significant as indicated by the p-value, and the 95% confidence interval not containing 0.

First difference model, with time trend, no lags:
Beta shows that within a year, for countries that experience a 1% increase in GDP per capita, CO2 emissions are expected to increase, on average, by 0.58% more.

First difference model, with time trend, 2-year lags:
A 1% increase in GDP per capita tends to be followed by a 0.73% increase in CO2 emissions within 2 years.
The coefficient for the first time lag is -0.31, and for the second time lag is 0.16. Hence, there is a 0.31 % decrease in CO2 emission per capita associated with a 1% increase in GDP per capita for the 1st year, and a 0.16 increase for the second. 

First difference model, with time trend, 6-year lags:
there is a -0.02 constant, meaning, that there is a 0.02 percentage point decrease in CO2 emission per capita associated with unchanged GDP per capita. 
A 1% increase in GDP per capita tends to be followed by a 0.74% increase in CO2 emissions within 6 years. 

Fixed effects model with time and country fixed effects:
In the fixed effect has been inserted a time dummy across all countries. 
On average, co2 emissions are expected to be 0.34% higher, compared to its mean within the cross-sectional countries and its mean, where and when GDP per capita is higher by 1% compared to its mean within the cross-sectional countries and its mean. 

Conclusions:
Based on the results provided, there is a positive relationship between GDP per capita and CO2 emissions per capita in the 28 European and Central Asian countries with high income. 
The use of fixed effects in first difference models provides a reasonable approximation to causality, as it accounts for time-invariant confounding variables. When fixed effects for time and countries are incorporated in the last model, a statistically significant rise in CO2 emissions is observed with an increase in GDP per capita, implying a possible causal relationship between the two variables. Nonetheless, to increase certainty, it is crucial to consider potential time-varying confounders, as the models used do not account for them.
