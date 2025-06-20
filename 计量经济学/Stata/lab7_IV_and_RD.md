# Lab7 IV and RD

## 7.1 工具变量IV

### 7.1.1 理论回顾

$$
y=\beta_{0}+\beta_{1}x_1+ \dots +\beta_{k}x_{k}+u \\
first \ stage: x_k=\alpha_{0}+\alpha_{1}x_1+ \dots +\alpha_{k-1}x_{k-1}+\gamma z+v \\
second \ stage: y=\beta_{0}+\beta_{1}x_1+ \dots +\beta_{k}\hat{x}_k+u
$$
### 7.1.2 代码实现

```stata
ivreg2 lnwage (educ=fatheduc) exper expersq , first robust savefp(first)
eststo second //estimates store
outreg2 [first second] using hw2_1_iv.doc, tstat bdec(3) tdec(2) replace //tstat表示将括号里的标准误改为t值；decimal,回归系数保留3位小数，t值保留2位小数

```

你的检验应该是ivreg2命令使用了orthog选项，用来检测工具变量的外生性，即工具变量与扰动项不相关。但是可以看到，你有一个认为内生的解释变量，而且你也只有一个工具变量，所以这属于“恰好识别”的情况，即工具变量个数等于内生解释变量的个数。在“过度识别”的（工具变量个数多于内生解释变量个数）情况下，你是可以这样检验外生性的，这是原假设为所有工具变量都是外生的，通过看C统计量的p值，你可以做出是否拒绝原假设的决定，如果拒绝，则认为至少一个工具变量不是外生的。但是，在恰好识别的情况下，目前公认无法检验工具变量的外生性，即工具变量与扰动项不相关。这种情况下，只能进行定性讨论或依赖于专家的意见。定性讨论基于以下逻辑：如果工具变量是外生的，则其对被解释变量发生影响的唯一渠道是通过内生解释变量，除此以外别无其他渠道。在实际操作中，则需要找出工具变量影响被解释变量的所有可能其他渠道，然后一一排除，才能比较信服地说明工具变量的外生性。

虽然在“恰好识别”情况下，难以检测外生性，但仍然可检测工具变量的相关性，即工具变量与内生解释变量相关。如果工具变量与内生解释变量完全不相关，则无法使用工具变量法；如果只是微弱地相关，则该工具变量是“弱工具变量”。可以在运行ivregress之后通过以下命令检验：
estat firststage, all forcenonrobust
此检验的原假设为：工具变量在第一阶段回归中的系数都为0。如果拒绝原假设，则认为工具变量满足相关性。如果存在弱工具变量，则应该：（1）寻找更强的工具变量 （2）使用对弱工具变量更不敏感的“有限信息最大似然估计法”，其stata命令为：
ivregress liml depvar [varlist1] (varlist2=instlist)

如果题注还想掌握更多的过于工具变量的检验的实战操作，推荐参考陈强的书《高级计量经济学及Stata应用》第二版，在第153-166页有详细的关于Stata命令及实例的介绍，跟着他的介绍自己动手操作一遍会更有收获。说实话，工具变量不好找，好的工具变量就更稀有了。

过度识别检验的原假设是所有工具变量都是外生的

### 7.1.3 一个例子



## 7.2 断点回归RD

### 7.2.1 理论回顾



### 7.2.2 代码实现

```stata
//总体散点图,难以看出断点处跳跃效果
twoway (scatter Y_all X_c,                       ///
	mcolor(black) xline(0, lcolor(black*0.3))),    ///
	graphregion(color(white)) ///
	ytitle(Outcome) xtitle(Score)

//rdplot，将数据划分为不同的bins，在每个bin的中点画出结果均值，并使用多项式拟合
preserve //暂存原始数据，这个主要是因为collapse会改变数据的个数，比如20个数据分为4组，则取均值就会将其变为一个只有4个观测值的数据集 
rdplot Y_all X_c, nbins(4 4) genvars support(-2 2) //nbins表示左右两侧各分为多少个bins, support表示X_c的取值范围。rdplot会在数据集里增加很多变量，包括下面collapse中的那三个,一个bin里面的每个观测值的rdplot_mean_x是一样的
gen obs = 1
collapse (mean) rdplot_mean_x rdplot_mean_y (sum) obs, by (rdplot_id) //collapse 命令用于将一个数据集中的若干数字变量 按组别转换为其平均值、总和、中位数等统计值形式。给出每个bin里面X_c和Y的均值，根据bin的id分组，负的id表示在左边的bin
order rdplot_id //按id排序
tabstat rdplot_mean_x rdplot_mean_y obs,by(rdplot_id)
restore //恢复原始数据

rd Y_all X_c, c(0) // rd 命令不仅给出了最优带宽，还同时给出了带宽取最优带宽50%和200%的回归结果（即处理变量D前面的回归系数）。


*************以下是HW2的practical exercise 3，使用了非参数方法(rdrobust)**********
use "$raw\mlda.dta", clear

*(1)
gen X_c= agecell-21    //running variable : age 减21是做中心化，21是cutoff
gen D=.
replace D=0 if X<0 & X!=.
replace D=1 if X>=0 & X!=.   //treatment variable: 大于等于21岁的取1
label var D "older than 21"
gen Xc_sq=X_c^2
gen Xc_D=X_c*D
gen Xc_sq_D=Xc_sq*D

rename all Y_all //outcome variable: 总计死亡人数（每10000人） 
rename internal Y_internal
rename external Y_external
rename mva Y_mva
rename alcohol Y_alcohol

save mlda_processed.dta, replace

*(2)
twoway (scatter Y_all X_c, msymbol(+) msize(*0.4) mcolor(black*0.3)),   title("散点图")
graph save scatter.gph,  replace
rdplot Y_all X_c, c(0) p(1) graph_options(title(线性拟合)) // 线性拟合图,c() 选项表示断点位置，不设定则默认为 0 ; p() 选项表示拟合的阶数
graph save rd1,  replace
rdplot Y_all X_c, c(0) p(2) graph_options(title(二次型拟合))//二次型拟合图
graph save rd2,  replace
graph combine scatter.gph rd1.gph rd2.gph
cap graph export rd_all.png, replace 

*(3)
//local
rdrobust Y_all X_c, c(0) p(1)
est store all_linear
rdrobust Y_all X_c, c(0) p(2)
est store all_quadratic
esttab all_linear all_quadratic using rd_all.rtf, mtitle ///
scalar(N) compress ///
star(* 0.1 ** 0.05 *** 0.01) ///
b(%6.3f) t(%6.3f) ///
title(Table: rd_all result) replace

//global
sum X_c
local hvalueR=r(max)  //往右多少，r用与于获取在summary中暂存的变量max的值，也即X_c的最大值
local hvalueL= abs(r(min)) //往左多少
rdrobust Y_all X_c, h(`hvalueL'  `hvalueR') //自动选择阶数
rdrobust Y_all X_c, h(`hvalueL'  `hvalueR') p(2) //二阶拟合

*(4)
preserve
keep if X_c>=-1 & X_c<=1
rdrobust Y_all X_c, c(0) p(1)
est store all_linear_limitsample
rdrobust Y_all X_c, c(0) p(2)
est store all_quadratic_limitsample
esttab all_linear_limitsample all_quadratic_limitsample using rd_all_limitsample.rtf, mtitle ///
scalar(N) compress ///
star(* 0.1 ** 0.05 *** 0.01) ///
b(%6.3f) t(%6.3f) ///
title(Table: rd_all_limitsample result) replace
restore

*(5)
rdrobust Y_internal X_c, c(0) p(1)
est store internal_linear
rdrobust Y_internal X_c, c(0) p(2)
est store internal_quadratic

rdrobust Y_external X_c, c(0) p(1)
est store external_linear
rdrobust Y_external X_c, c(0) p(2)
est store external_quadratic

rdrobust Y_mva X_c, c(0) p(1)
est store mva_linear
rdrobust Y_mva X_c, c(0) p(2)
est store mva_quadratic

rdrobust Y_alcohol X_c, c(0) p(1)
est store alcohol_linear
rdrobust Y_alcohol X_c, c(0) p(2)
est store alcohol_quadratic

esttab internal_linear internal_quadratic external_linear external_quadratic mva_linear mva_quadratic alcohol_linear alcohol_quadratic using rd_other_outcomes.rtf, mtitle ///
scalar(N) compress ///
star(* 0.1 ** 0.05 *** 0.01) ///
b(%6.3f) t(%6.3f) ///
title(Table: rd_other_outcomes result) replace

```



### 7.2.3 例子：Sharp RDD





### 7.2.4 例子：Fuzzy RDD