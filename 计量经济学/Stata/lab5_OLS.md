# Lab5 Tables and OLS

## 5.1 t检验

假设检验

```stata
*检验总体均值是否为6000 
ttest price == 6000 if foreign == 0 ,level(90)
ttest hwage, by(female)

*检验两组样本的标准差是否相等 
* 方差齐性检验(F检验)
* 对两个独立样本进行比较的时候，首先要判断两总体方差是否相同，即方差齐性。
* 若两总体方差相等equal variances(方差齐)，则直接用t检验;
* 若方差不齐，选择unequal variances(方差不齐)的均值T检验去做,加unequal选项。
sdtest price, by(foreign)

*检验两组样本的总体均值是否相等（方差相等）
*Two-sample t test with equal variances
 ttest price, by(foreign) 

*多变量均值比较表格输出-ttable2-
ssc install ttable2
sysuse auto,clear
ttable2 price wei len mpg, by(foreign) f(%6.2f)
```



## 5.3 协方差矩阵

```stata
help math functions

*相关性
corr citycode educ,c
pwcorr iq s, star(.01) //Significant positive correlation at the level of 1%, correlation coefficient = 0.51.
```





## 5.4 OLS 估计

### 5.4.1 数据分析流程



### 5.4.2 OLS理论回顾



### 5.4.3 OLS的代码实现

```stata
reg anualwage educ exper, r
```



### 5.4.4 输出OLS结果表格

```stata
esttab ols_basic ols_with_covariates tsls_fatheduc using hw2_pe1_reg.rtf, scalar(r2 r2_a N F) compress ///
star(* 0.1 ** 0.05 *** 0.01) ///
b(%6.3f) t(%6.3f) r2(%9.3f) ar2 ///
mtitles("ols_basic" "ols_with_covariates" "tsls_fatheduc") ///
title(esttab_Table: regression result) replace

```

注：esttab 括号里面默认是t值