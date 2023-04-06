cd C:\Users\Binati_Jacopo\Desktop\stata2\datafinale.csv
import delimited "C:\Users\Binati_Jacopo\Desktop\stata2\datafinale.csv", varnames(1) stringcols(3 4) numericcols(1 5 6 7) 
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
                                                F(1, 26)          =       8.39
                                                Prob > F          =     0.0076
                                                R-squared         =     0.3670
                                                Root MSE          =     .30234

------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |   .5352659   .1848301     2.90   0.008     .1553421    .9151897
       _cons |  -10.45535   1.942783    -5.38   0.000     -14.4488   -6.461905
------------------------------------------------------------------------------
*/

*cross sectional OLS for a yearr of your choice
reg ln_co2 lngdpxcapita if year == 2019, robust
/*
Linear regression                               Number of obs     =         28
                                                F(1, 26)          =       4.99
                                                Prob > F          =     0.0343
                                                R-squared         =     0.2250
                                                Root MSE          =     .29453

------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |   .4711963   .2108998     2.23   0.034     .0376856     .904707
       _cons |  -10.18909   2.246774    -4.53   0.000     -14.8074   -5.570778
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
Linear regression                               Number of obs     =        741
                                                F(1, 27)          =     150.27
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1199
                                                Root MSE          =     .05256

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |   .6170666   .0503383    12.26   0.000     .5137809    .7203524
       _cons |  -.0239477   .0020689   -11.58   0.000    -.0281926   -.0197028
------------------------------------------------------------------------------
*/

*FD MODEL, WITH TIME TREND, 2 YEAR LAGS
reg d_ln_co2 L(0/2).d_gdpxcap, cluster(country)

/*
Linear regression                               Number of obs     =        685
                                                F(3, 27)          =      53.77
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1377
                                                Root MSE          =     .05272

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |
         --. |   .7340696   .0935401     7.85   0.000     .5421412     .925998
         L1. |  -.2588136   .1307004    -1.98   0.058    -.5269885    .0093614
         L2. |   .1405132   .0862489     1.63   0.115    -.0364548    .3174812
             |
       _cons |  -.0247467   .0020351   -12.16   0.000    -.0289224   -.0205711
------------------------------------------------------------------------------
*/

*FD MODEL, WITH TIME TREND, 6 YEAR LAGS
reg d_ln_co2 L(0/6).d_gdpxcap, cluster(country)
/*
Linear regression                               Number of obs     =        573
                                                F(7, 27)          =      28.56
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1719
                                                Root MSE          =     .05128

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
    d_ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   d_gdpxcap |
         --. |   .7563894   .1063843     7.11   0.000     .5381068     .974672
         L1. |  -.3309447    .148122    -2.23   0.034    -.6348659   -.0270235
         L2. |   .1750488   .0948101     1.85   0.076    -.0194855     .369583
         L3. |   .0669098   .0915305     0.73   0.471    -.1208953    .2547148
         L4. |  -.1232281   .0992345    -1.24   0.225    -.3268404    .0803843
         L5. |   .1339849    .059102     2.27   0.032     .0127175    .2552523
         L6. |   .0618928   .0941132     0.66   0.516    -.1312115     .254997
             |
       _cons |  -.0281936   .0025646   -10.99   0.000    -.0334557   -.0229315
------------------------------------------------------------------------------
*/

*FE MODELWITH TIME AND COUNTRY FIXED EFFECTS
xtreg ln_co2 lngdpxcapita i.year, fe cluster(country)

/* 
Fixed-effects (within) regression               Number of obs      =       769
Group variable: id                              Number of groups   =        28

R-sq:  Within  = 0.6104                         Obs per group: min =        25
       Between = 0.2973                                        avg =      27.5
       Overall = 0.3271                                        max =        28

                                                F(27,27)           =         .
corr(u_i, Xb)  = 0.1707                         Prob > F           =         .

                               (Std. err. adjusted for 28 clusters in country)
------------------------------------------------------------------------------
             |               Robust
      ln_co2 | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
lngdpxcapita |   .3056687     .08848     3.45   0.002     .1241227    .4872147
             |
        year |
       1993  |  -.0113952   .0071618    -1.59   0.123      -.02609    .0032995
       1994  |  -.0168002   .0132533    -1.27   0.216    -.0439938    .0103934
       1995  |  -.0403867   .0232067    -1.74   0.093    -.0880028    .0072295
       1996  |  -.0137366   .0258387    -0.53   0.599    -.0667533    .0392801
       1997  |  -.0432055   .0269147    -1.61   0.120    -.0984299    .0120188
       1998  |  -.0537039    .032885    -1.63   0.114    -.1211782    .0137705
       1999  |   -.079729   .0390827    -2.04   0.051    -.1599202    .0004622
       2000  |  -.1025567   .0421005    -2.44   0.022    -.1889398   -.0161737
       2001  |  -.0870084   .0415066    -2.10   0.046    -.1721729   -.0018439
       2002  |  -.0933346   .0442727    -2.11   0.044    -.1841748   -.0024945
       2003  |  -.0677722   .0445716    -1.52   0.140    -.1592254    .0236811
       2004  |  -.0800241   .0468355    -1.71   0.099    -.1761226    .0160745
       2005  |  -.0984476   .0500622    -1.97   0.060    -.2011667    .0042715
       2006  |  -.1097064    .049829    -2.20   0.036    -.2119471   -.0074656
       2007  |  -.1305188   .0525328    -2.48   0.019    -.2383072   -.0227303
       2008  |  -.1622826   .0525968    -3.09   0.005    -.2702024   -.0543629
       2009  |  -.2230986   .0501972    -4.44   0.000    -.3260948   -.1201023
       2010  |  -.2023125   .0477187    -4.24   0.000    -.3002231   -.1044018
       2011  |  -.2515637   .0507487    -4.96   0.000    -.3556914    -.147436
       2012  |  -.2857325   .0513097    -5.57   0.000    -.3910113   -.1804537
       2013  |  -.3090427   .0508449    -6.08   0.000    -.4133677   -.2047176
       2014  |  -.3639956   .0546702    -6.66   0.000    -.4761695   -.2518216
       2015  |   -.371035   .0607535    -6.11   0.000    -.4956908   -.2463792
       2016  |  -.3813464   .0618436    -6.17   0.000    -.5082389   -.2544538
       2017  |  -.3866286   .0670642    -5.77   0.000     -.524233   -.2490243
       2018  |  -.4147835   .0671096    -6.18   0.000     -.552481   -.2770859
       2019  |  -.4746213    .072223    -6.57   0.000    -.6228106    -.326432
             |
       _cons |  -7.936027    .900973    -8.81   0.000     -9.78467   -6.087383
-------------+----------------------------------------------------------------
     sigma_u |  .31251243
     sigma_e |  .08928002
         rho |  .92454275   (fraction of variance due to u_i)
------------------------------------------------------------------------------
*/

