
cd "C:\.."
	*********************************************
	* After UMAP we process the Tobit regression * 
	*********************************************
*
import excel "Tobit data.xlsx", sheet("Sheet1") firstrow case(lower) clear
encode dmu, gen(dmu_id)
drop dmu 
rename dmu_id dmu 
xtset dmu year

global xlist "tm sm po tbs ds mc ps dt"
global xlist2 "tm_1 tm_2 sm_1 sm_2 sm_3 po_1 po_2 po_3 po_4 po_5 po_6 tbs_1 tbs_2 tbs_3 tbs_4 tbs_5 tbs_6 ds_1 ds_2 ds_3 mc_1  mc_2 mc_3 ps_1 ps_2 dt_1 dt_2 dt_3"
global xlist3 "eff1 eff2 eff3 eff4 eff5 eff6 eff7 eff8 eff9 eff10  eff11 eff12 eff13 eff14 eff15"

egen region_numeric = group(region)
egen province_numeric = group(province)
egen robot_sort = max(robot_eff != 0)
replace robot_sort = 0 if robot_eff == 1


***********VIF************
reg eff  $xlist
logout,save(共线性)word replace: estat vif
**********VIF******************

	*********************************************
	* PCA method *
	*********************************************
pca $xlist2 , comp(8) vce(normal)
estat anti
estat kmo   /*KMO检验，越高越好,最少大于0.5*/
estat loadings
estat residuals
estat smc  /*SMC检验，值越高越好*/
estat summarize
screeplot , yline(2.445) ylabel(, valuelabel)
rotate
scoreplot, com(2)  xline(0) yline(0)
loadingplot, com(2) xline(0.05) yline(-0.1)
	*************PCA over*********************

	
	
	
*****************Observation****************************
summarize $xlist


histogram eff, normal bin(12) xline(1) fcolor(green) lcolor(white)
histogram robot_eff, normal bin(12) xline(1) fcolor(green) lcolor(white)
graph matrix eff robot_eff $xlist, half jitter(2)
logout,save(相关分析)word replace:pwcorr_a   eff  $xlist robot_eff
*****************Observation******************************************


	*********************************************
	* Sort and Tobit regression * 
	*********************************************
tobit eff  robot_eff , ll(0)  //nolog vce(cluster province_numeric)
// tobit eff  robot_eff $xlist i.year, ll(0)  nolog vce(cluster region_numeric)
// tobit eff eff* robot_eff $xlist , ll(0)   nolog vce(cluster province_numeric)
tobit eff  $xlist , ll(0)  // nolog vce(cluster region_numeric)


*****************************************
*3个阶段扩展测算*
*****************************************
egen stage1 = rowmean(eff1 eff2 eff3)
egen stage2 = rowmean( eff4 eff5 eff6 eff7 eff8)
egen stage3 = rowmean(eff11 eff12 eff13 eff15 )

logout,save(相关分析)word replace:pwcorr_a   eff  robot_eff stage1 stage2 stage3 



*****************************************
*Tobit regression and the comparison of Robust*
*****************************************

tobit eff $xlist , ll(0) 
//comparison Robust
tobit eff $xlist , ll(0)  nolog vce(cluster robot_sort)
est store tobit_01
tobit eff $xlist , ll(0)  nolog vce(cluster region_numeric)
est store tobit_02
tobit eff tm po tbs mc ps dt robot_eff stage*, ll(0) nolog vce(cluster region_numeric)
est store tobit_03
tobit eff tm po tbs mc ps dt  stage* if(robot_sort==1), ll(0) vce(bootstrap)  
est store tobit_04
tobit eff tm po tbs mc ps dt stage* c.province_numeric#c.province_numeric , ll(0) nolog vce(cluster region_numeric)
est store tobit_05
xttobit eff  tm po tbs mc ps dt robot_eff stage*  if(robot_sort==1) , tobit ll(0) 
est store tobit_06
esttab  tobit_01 tobit_02 tobit_03 tobit_04 tobit_05 tobit_06 using tobit_regression_result.rtf,replace nogap ar2 b(%6.4f) t(%6.4f) star(* 0.1 ** 0.05 *** 0.01)   //再导出word



       webuse mroz87, clear
//     Censored from below at zero
// tobit whrs75 nwinc wedyrs wexper c.wexper#c.wexper wifeage kl6 k618, ll(0)









