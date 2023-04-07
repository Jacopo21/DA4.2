cd C:\Users\Binati_Jacopo\Desktop\stata2\datafinale.csv
import delimited "C:\Users\Binati_Jacopo\Desktop\stata2\datafinale1.csv", varnames(1) stringcols(3 4) numericcols(1 5 6 7) 
save C:\Users\Binati_Jacopo\Desktop\stata2\stata.dta, replace

*checking the avriables
drop timecode
rename countryname country 
rename time year
rename co2emissionsktenatmco2ekt co2emission 
rename populationtotalsppoptotl population
rename gdppercapitapppconstant2017inter gdpxcapita
replace country = subinstr(country, " ", "_", .)

*sorting
sort country year
order year country countrycode gdpxcapita co2emission
drop in 1/5
*dropping some countries which have no data
drop if country == "Andorra"
drop if country == "Greenland"
drop if country == "Liechtenstein"
drop if country == "San_Marino"

*generating new varibales of co2 emission per capita
gen co2xcapita = co2emission/population
lab var co2xcapita "CO2 emitted per capita in kt"
gen lngdpxcapita = ln(gdpxcapita)
lab var lngdpxcapita "Logarithm of GDP per capita"
*******************************


*Cross sectional for year == 2005
reg ln_co2 lngdpxcapita if year == 2005, robust
/*
Linear regression                               Number of obs     =         28
                                                F(1, 26)          =      11.49
                                                Prob > F          =     0.0022
                                                R-squared         =     0.4123
                                                Root MSE          =     .31758

------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |   .5960574   .1758155     3.39   0.002     .2346635    .9574514
       _cons |  -11.11119   1.850381    -6.00   0.000     -14.9147   -7.307679
------------------------------------------------------------------------------
*/

*cross sectional OLS for a yearr of your choice
reg ln_co2 lngdpxcapita if year == 2019, robust
/*
Linear regression                               Number of obs     =         28
                                                F(1, 26)          =       6.16
                                                Prob > F          =     0.0198
                                                R-squared         =     0.2510
                                                Root MSE          =     .29722

------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |    .499054   .2010434     2.48   0.020     .0858034    .9123046
       _cons |  -10.49688   2.139374    -4.91   0.000    -14.89443   -6.099333
------------------------------------------------------------------------------
*/

*generating country codes
egen id = group(country)
tab id
lab var id "ID of each country"
gen ln_co2 = ln(co2xcapita)

xtset id year, yearly

gen d_ln_co2 = d.ln_co2
gen d_gdpxcap = d.lngdpxcapita


*FD model, with time trend, no lags
reg d_ln_co2 d_gdpxcap, cluster(country)
/*
Linear regression                               Number of obs     =        738
                                                F(1, 27)          =     105.66
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1136
                                                Root MSE          =      .0533

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |   .5838461   .0567992    10.28   0.000     .4673039    .7003883
       _cons |  -.0235848   .0021948   -10.75   0.000    -.0280881   -.0190814
------------------------------------------------------------------------------
*/

*FD MODEL, WITH TIME TREND, 2 YEAR LAGS
reg d_ln_co2 L(0/2).d_gdpxcap, cluster(country)

/*
Linear regression                               Number of obs     =        682
                                                F(3, 27)          =      43.88
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1388
                                                Root MSE          =     .05328

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |
         --. |   .7313388   .0907604     8.06   0.000     .5451138    .9175639
         L1. |  -.3157389   .1357527    -2.33   0.028    -.5942804   -.0371974
         L2. |   .1647681   .0868026     1.90   0.068     -.013336    .3428723
             |
       _cons |  -.0241183   .0022169   -10.88   0.000    -.0286671   -.0195695
------------------------------------------------------------------------------
*/

*FD MODEL, WITH TIME TREND, 6 YEAR LAGS
reg d_ln_co2 L(0/6).d_gdpxcap, cluster(country)
/*
Linear regression                               Number of obs     =        570
                                                F(7, 27)          =      24.51
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1797
                                                Root MSE          =     .05162

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |
         --. |   .7400842     .10308     7.18   0.000     .5285814    .9515869
         L1. |  -.3820821   .1499504    -2.55   0.017    -.6897549   -.0744092
         L2. |    .190321   .0941674     2.02   0.053    -.0028946    .3835367
         L3. |   .1174136   .0973503     1.21   0.238    -.0823327      .31716
         L4. |  -.1214405    .097928    -1.24   0.226    -.3223721    .0794912
         L5. |   .1383562   .0578828     2.39   0.024     .0195906    .2571218
         L6. |   .0676565   .0890764     0.76   0.454    -.1151131    .2504262
             |
       _cons |  -.0285007   .0026284   -10.84   0.000    -.0338937   -.0231077
------------------------------------------------------------------------------
*/

*FE MODELWITH TIME AND COUNTRY FIXED EFFECTS
xtreg ln_co2 lngdpxcapita i.year, fe cluster(country)

/* 
Fixed-effects (within) regression               Number of obs      =       766
Group variable: id                              Number of groups   =        28

R-sq:  Within  = 0.5891                         Obs per group: min =        25
       Between = 0.3502                                        avg =      27.4
       Overall = 0.3650                                        max =        28

                                                F(27,27)           =         .
corr(u_i, Xb)  = 0.1981                         Prob > F           =         .

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |   .3413981   .0839572     4.07   0.000     .1691322     .513664
             |
        year |
       1993  |  -.0133878   .0071567    -1.87   0.072    -.0280721    .0012964
       1994  |  -.0204447   .0136066    -1.50   0.145    -.0483631    .0074737
       1995  |  -.0397891   .0244659    -1.63   0.116    -.0899891    .0104108
       1996  |    -.01566   .0267359    -0.59   0.563    -.0705176    .0391976
       1997  |  -.0489649   .0276034    -1.77   0.087    -.1056024    .0076725
       1998  |  -.0634263   .0337537    -1.88   0.071    -.1326833    .0058307
       1999  |  -.0934845   .0396285    -2.36   0.026    -.1747955   -.0121736
       2000  |  -.1213831    .042538    -2.85   0.008    -.2086638   -.0341023
       2001  |  -.1034416   .0420999    -2.46   0.021    -.1898235   -.0170597
       2002  |  -.1111627   .0449393    -2.47   0.020    -.2033705   -.0189548
       2003  |  -.0883421   .0453589    -1.95   0.062    -.1814109    .0047267
       2004  |  -.1012093   .0479949    -2.11   0.044    -.1996866    -.002732
       2005  |  -.1208136      .0516    -2.34   0.027    -.2266881   -.0149391
       2006  |  -.1319789   .0510193    -2.59   0.015    -.2366619    -.027296
       2007  |  -.1542098   .0537693    -2.87   0.008    -.2645352   -.0438844
       2008  |  -.1873805   .0536419    -3.49   0.002    -.2974445   -.0773165
       2009  |  -.2464163   .0507429    -4.86   0.000    -.3505322   -.1423005
       2010  |  -.2175741   .0481127    -4.52   0.000    -.3162931   -.1188551
       2011  |  -.2683935     .05135    -5.23   0.000    -.3737549    -.163032
       2012  |  -.3020846   .0526912    -5.73   0.000     -.410198   -.1939712
       2013  |  -.3229159   .0527239    -6.12   0.000    -.4310964   -.2147355
       2014  |  -.3811565   .0559134    -6.82   0.000    -.4958814   -.2664316
       2015  |  -.3887082   .0618907    -6.28   0.000    -.5156974   -.2617189
       2016  |  -.4015555    .063031    -6.37   0.000    -.5308844   -.2722267
       2017  |  -.4080929   .0681697    -5.99   0.000    -.5479655   -.2682203
       2018  |  -.4326707   .0676355    -6.40   0.000    -.5714473    -.293894
       2019  |  -.4936119   .0719872    -6.86   0.000    -.6413175   -.3459064
             |
       _cons |  -8.309636   .8525162    -9.75   0.000    -10.05885   -6.560417
-------------+----------------------------------------------------------------
     sigma_u |  .32328465
     sigma_e |  .09141116
         rho |  .92596725   (fraction of variance due to u_i)
------------------------------------------------------------------------------
*/

