# Lab4 画图

## 4.1 介绍

1. 图片类型

```stata
*直方图
histogram varname [if] [in] [weight] [, [continuous_opts | discrete_opts] options]
histogram mpg, discrete by(foreign) //直方图

*密度函数图
gen lmpg=ln(mpg)
kdensity lmpg,normal //概率密度函数

*相关系数矩阵图
graph matrix price wei len mpg //相关系数矩阵

*柱形图
graph bar (mean)anualwage, over (female)

```

scatter 散点图；lfit 线性回归曲线； lfitci 显示置信区间

```stata
*把多张子图画在一张图上，每一个小括号里都是一个子图，或者用两个竖线隔开

graph twoway (scatter anualwage educ) (lfit anualwage educ) (lfitci anualwage educ)
graph twoway scatter anualwage educ || lfit anualwage educ || lfitci anualwage educ

*函数图
twoway (function probit=normal(0.031*x+0.712), range(0 60))(function logit=1/(1+exp(-1.059-0.04*x)), range(0 60)), ///
xtitle("Experience(years)") ytitle("Probability of Passing") ///
saving(probit_logit.gph, replace)
cap graph export probit_logit.png, replace //11.2(b)

```

## 4.2 管理



## 4.3 title选项









## 4.7 line选项

```stata
 * 线型的控制
 help connect_options
 help linepatternstyle
 help linestyle
   sysuse sp500, clear
   twoway connect open close  low date in 1/10
   twoway connect open close  low date in 1/10, lstyle(p1 p1solid)
   twoway connect open close  low date in 1/10, lstyle(p1 p1solid p3mark)
```



## 4.8 text选项



## 4.9 marker和marker_label选项

数据点的格式

```stata
*marker（点）and line（线）
*mcolor是选择点的颜色，xline(0)表示在图上画出x=0这条线
twoway (scatter Y X_c,                       ///
	mcolor(black) xline(0, lcolor(black))),    ///
	graphregion(color(white)) ///
	ytitle(Outcome) xtitle(Score)
twoway (scatter Y X_c, msymbol(+) msize(*0.4) mcolor(black*0.3)),   title("散点图")
```



## 4.10 by选项

用于分组绘图



## 4.11 线性拟合图

