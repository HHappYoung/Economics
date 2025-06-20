
	// 改变工作路径
	cd "C:\Users\AlphaStat\Nutstore\.nutstore_emh1aG9uZ19iaW5nQDE2My5jb20=\我的坚果云\日常工作文件夹\Example\"

	//
	local i = 1
	foreach var in Return TurnOver IH QRISD QC{
		readWind `var', key(原始数据) timeType(q) t0(2010q1) tn(2017q2) type(xlsx) sheet(`i') tostring
		local i = `i' + 1
		save `var', replace
	}
	
	//
	use Return.dta, clear
	merge 1:1 stkcd date using TurnOver.dta, nogen keep(3)
	merge 1:1 stkcd date using IH.dta, nogen keep(3)
	merge 1:1 stkcd date using QRISD.dta, nogen keep(3)
	merge 1:1 stkcd date using QC.dta, nogen keep(3)
	
	//
	destring _all, replace
	rename date Time
	
	//
	label var Return "股票收益率"
	label var TurnOver "换手率%"
	label var IH "机构总持股比例"
	label var QRISD "季度平均股票收益波动率"
	label var QC "流通市值季度均值"
	
	
	
	
	// 定义面板数据类型
	tsset stkcd Time
	
	xtset stkcd Time
	
	
	
	// 描述统计
	tabstat QRISD IH Return TurnOver QC, c(s) s(mean sd cv min p25 p50 p75 max)
	
	

	// 相关分析
	pwcorr QRISD IH Return TurnOver QC,sig
	
	
	// 模式设定检验
	*-豪斯曼检验：随机效应 VS 固定效应
	qui xtreg QRISD IH Return TurnOver QC i.Time,fe
	est store fe
	qui xtreg QRISD IH Return TurnOver QC i.Time,re
	est store re
	hausman fe re, sigmamore
	sca Hausman=r(chi2)
	sca Pvalue=r(p)
	
	* LM检验,H0：混合效应 VS 随机效应
	xtreg QRISD IH Return TurnOver QC, re
	xttest0

	* F检验,H0：混合效应 VS 固定效应
	xtreg QRISD IH Return TurnOver QC i.Time, fe
		
	
	// 模式估计
	*-模型1
	reg QRISD IH Return TurnOver QC, r
	est store model1
	
	*-模型2
	xtreg QRISD IH Return TurnOver QC,fe r
	est store model2
	
	*-模型3
	xtreg QRISD IH Return TurnOver QC i.Time,fe cluster(stkcd)
	estadd sca Hausman=Hausman
	estadd sca Pvalue=Pvalue
	est store model3
	
	*-列出回归结果
	esttab  model1 model2 model3 ,  ///
			cells(b(star fmt(%9.4f)) se(par))                                ///
			stats(N Hausman Pvalue r2_a F,fmt(%9.0g %9.4f))              ///
			star(* 0.10 ** 0.05 *** 0.01) nogap compress                     ///
			mtitle(Mixed 1-fe 2-fe)                                          ///
			indicate("YEAR=*.Time*")
	

	
	

	