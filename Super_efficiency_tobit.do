	 **************************************************
     *  Paper： .....  *
	 **************************************************	 
	 
*Notes：1、Stata Version 17.0; 
*       2、Data Resource：A Empirical Research of commercial residential project   	
	
	 **************************************************
     *          Part 1：Data cleaning                 *
	 **************************************************	 
	 
//	 Read Data
cd "C:\..."  //Personal folder setting
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

