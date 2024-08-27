	 **************************************************
     *  Paper： .....  *
	 **************************************************	 
	 
*Notes：1、Stata Version 17.0; 
*       2、Data Resource：A Empirical Research of commercial residential project   	
	
	 **************************************************
     *          Part 1：Data cleaning                 *
	 **************************************************	 
	 
//	 Read Data
cd "C:\bgy\C-documents\碧桂园\综合管理\职称\博士相关\UPM\Empirical analysis DEA method\code\0. Province maps with project locations\Descriptive statistics"  //Personal folder setting
clear
use "DMU in and output_combined.dta"
* Variable Rename *
label variable x1 "NE(People)"
label variable x2 "LA(Square meters)"
label variable x3 "IP(Million CNY)"
label variable x4 "DDU(Months)"
label variable y1 "ACWP(Million CNY)"
label variable y2 "NSU(Set)"
label variable y3 "BIN(Million CNY)"

//Check missing 
egen mis = rowmiss(_all)  //生成一列数，缺几个空得几
summarize mis, detail   //观察缺了几个,如果不是0
list if missing(x1) | missing(x2) | missing(x3) | missing(x4) | missing(y1) | missing(y2) | missing(y3)
drop mis

// // Zero instead of 0.0001 for SBM calculation
// foreach var of varlist x1 x2 x3 y1 y2 y3 x4 {
//     replace `var' = 0.0001 if `var' == 0
// }    //这段代码会遍历变量x1、x2、y1、y2、y3、y4，并将这些变量中所有等于0的值替换为0.0001

	 **************************************************
     *          Part 2：Descriptive statistics         *
	 **************************************************	
generate temp_id = _n
sort region   // Category by Region
logout,save(Basic_Descripive_stat)word replace: by region: tabstat x1 x2 x3 x4 y1 y2 y3, s(N mean p25 p50 sd min max) f(%12.3f) c(s)   // Descriptive Statistics
// sum  x1 x2 x3 x4 y1 y2 y3 

	 **************************************************
     *          Part 3：Super-efficiency SBM model     *
	 **************************************************	
sort temp_id   // Category by temp_id 
	 * This part of the manual switch was performed using the Matlab tool
	 * !!!After completing the calculations, [copy+Paste] the efficiency values into dataset.

rename eg_ct eff
egen rank = rank(-eff)  //Create new var with rank values
sort region   // Category by Region
rename s_x1 NE_Slack
rename s_x2 LA_Slack
rename s_x3 IP_Slack
rename s_x4 DDU_Slack
rename s_y1 ACWP_Slack
rename s_y2 NSU_Slack
rename s_y3 BIN_Slack

egen mean_eff = mean(eff), by(region) // 使用 egen 命令计算 "eff" 变量的平均数，并以 "region" 为分类标签
export excel region mean_eff id temp_id year  eff rank NE_Slack LA_Slack IP_Slack DDU_Slack ACWP_Slack NSU_Slack BIN_Slack using "eff_with_rank.xlsx", firstrow(variables) replace

// import excel "eff_with_rank.xlsx", sheet("Sheet1") firstrow clear
// export excel id year region eff rank mean_eff using "eff_with_rank.xlsx", firstrow(variables) replace  //计算后再保存
// shell rm "eff_with_rank.xlsx" // 使用文件管理命令删除 "eff_with_rank.xlsx" 文件



	 **************************************************
     *          Part 4：Tobit regression model       *
	 **************************************************	












