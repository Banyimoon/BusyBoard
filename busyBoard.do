*! Paper: Busy Board, Scale Effect and Firm Performance: Evidence from China
*! Edit Time: 2015/3/13
*! Enviornment: Windows 7, Stata 12.0 SE
*! Author: Banyimoon

* Raw Data Source:
*	CSMAR and its sub database:
*		China Stock Market Trading Database(中国股票市场交易数据库)
*		China Stock Market Financial Statements Database(中国上市公司财务报表数据库)
*		China Stock Market Financial Database - Financial Indices(中国上市公司财务指标分析数据库)
*		China Listed Firm's Shareholders Research Database(中国上市公司股东研究数据库)
*		China Listed Firm's Corporate Governance Research Database(中国上市公司治理结构数据库)
*	List of CSI300 Constituent Stocks:
*		http://www.csindex.com.cn/sseportal/ps/zhs/hqjt/csi/000300cons.xls

* Packages Needed:
*	xtivreg2, esttab
*	(You can install theses packages by command: ssc install PackageName)


*********************************** Part 1: Import Raw Data ***********************************
* All raw data are in the folder "rawData" at your working directory
clear
set more off
global wd E:\proj\busyBoard
cd $wd

* Input raw data and convert to dta file
capture mkdir processingData
shell xcopy "E:\proj\busyBoard\rawData" "E:\proj\busyBoard\processingData" /-Y
cd processingData
local fileList: dir "$wd\processingData" file "*.zip"
foreach i in `fileList'{
	unzipfile `i', replace
}
* Be careful!!! Some files in different zip file are the same name and they will be replaced and lost
* So you should unzip and rename them manully
local xlsFileList: dir "$wd\processingData" file "*.xls*"
//odbc load, dsn("Excel Files;DBQ=$wd\processingData\CG_Rzgddw.xls") table("CG_Rzgddw$")
//import excel using CG_Rzgddw.xls, firstrow clear
foreach i in `xlsFileList'{
	/*
	*CG_Director.xlsx is too big which is almost 42MB!!!!
	*If your memory is not enough, you can drop the column D0801c and D301b manully which 
	//is directors' brief introduction and is useless for the paper but really big
	if ("`i'" == "CG_Director.xlsx") {
		set excelxlsxlargefile on
		import excel using `i', firstrow clear
		drop if _n==1 | _n==2
		local xlsName = substr("`i'",1,length("`i'")-5)
		save "`xlsName'.dta" ,replace
		set excelxlsxlargefile off
		continue
	}
	*/
	if ("`i'" == "CG_Director.xlsx") {
		continue
	}
	import excel using `i', firstrow clear
	if ("`i'" != "000300cons.xls") {
		drop if _n==1 | _n==2 //The first two rows are Chinese description and unit
	}
	export excel using `i', firstrow(variable) replace
	import excel using `i', firstrow clear
	if (strpos("`i'",".")==length("`i'")-3){
		local xlsName = substr("`i'",1,length("`i'")-4)
	}
	else {
		local xlsName = substr("`i'",1,length("`i'")-5)
	}
	save "`xlsName'.dta" ,replace
}

* Rename and label the data and variables
shell rename "E:\proj\busyBoard\processingData\000300cons.dta" "csi300.dta"
shell rename "E:\proj\busyBoard\processingData\CG_Agm.dta" "meeting.dta"
use meeting, clear
rename a0101b meetings
label variable meetings "Board Meetings"
save meeting, replace
shell rename "E:\proj\busyBoard\processingData\CG_Capchg.dta" "shares.dta"
use shares, clear
rename nshrttl shares
label variable shares "Total Shares Outstanding"
save shares, replace
shell rename "E:\proj\busyBoard\processingData\CG_Director.dta" "director.dta"
use director, clear
append using CG_Director1.dta
rename d0101b name
label variable name "Director's Name"
rename d0201a positionID
label variable positionID "ID of Director's Position"
rename d0201b position
label variable position "Director's Position Name"
rename d0301b gender
label variable gender "Director's Gender"
rename d0401b age
label variable age "Director's Age"
rename d0501b edu
label variable edu "Director's Education"
rename d0601b positionTitle
label variable positionTitle "Director's Position Title"
rename d0701b staTime
label variable staTime "Director's Start Time Served"
rename d0702b endTime
label variable endTime "Director's End Time Served"
rename d0901b getPaid
label variable getPaid "1 for got paid from Company, 0 otherwise"
rename d1001b compensation
label variable compensation "Director's Compensation"
rename d1002b bonus
label variable bonus "Director's Bonus"
rename d1101b shareHold
label variable shareHold "Director's Shares Holding"
rename d1201b cocurPost
label variable cocurPost "1 for director holding cocurrent position, 0 otherwise"
save director, replace
shell rename "E:\proj\busyBoard\processingData\cg_rzgddw.dta" "partTime.dta"
use partTime, clear
forval i = 1/6 {
	append using cg_rzgddw`i'.dta
}
rename Stkcd stkcd
destring stkcd, replace
rename Reptdt reptdt
rename D0101b name
label variable name "Director's Name"
rename D0102b partTimeCorp
label variable partTimeCorp "Director's Cocurrent Position Corporation or Organizaion"
rename D0103b shareholderCorp
label variable shareholderCorp "1 for part-time corporate is shareholder of listed firm, 2 for not, 3 for uncertian"
rename D0105b partTimePost
label variable partTimePost "Director's Part-time Position"
save partTime, replace
shell rename "E:\proj\busyBoard\processingData\cg_ybasic.dta" "board.dta"
use board, clear
rename Stkcd stkcd
destring stkcd, replace
rename Reptdt reptdt
rename Annodt annodt
label variable annodt "Report Announcement Date"
rename Y0301b stkStr
label variable stkStr "1 for share structure changed, 0 ohterwise"
rename Y0401b shhol
label variable shhol "Total Shareholders"
rename Y0501b shholRelated
label variable shholRelated "1 for existed top 10 shareholders are related to the listed company, 0 otherwise"
rename Y0601b employee
label variable employee "Total Employees"
rename Y0701b retire
label variable retire "Total Retire Employees"
rename Y0801b boardChairman
label variable boardChairman "Chairman of Board"
rename Y0901b genMan
label variable genMan "Genernal Manager"
rename Y1001b ChairGenSame
label variable ChairGenSame "1 for Chairman of Board and General Manager are the same person, 0 otherwise"
rename Y1101a totDir
label variable totDir "Total Directors"
rename Y1101b totIndDir
label variable totIndDir "Total Independent Directors"
rename Y1201a totSup
label variable totSup "Total Board of Supervisors"
rename Y1301b totExe
label variable totExe "Total Executives"
rename Bddihldn boardHolding
label variable boardHolding "Board Share Holding"
rename Bsuphldn supHolding
label variable supHolding "Board of Supervisors Share Holding"
rename Excuhldn exeHolding
label variable exeHolding "Executives Share Holding"
rename Mngmhldn manHolding
label variable manHolding "Management Share Holding"
rename Y1501a totCompen
label variable totCompen "Total Compensation of Board, Supervisors and Executives"
save board, replace
use CG_Ybasic_, clear
rename y1701a committee
label variable committee "Total Committees"
rename y1701b mainCommittee
label variable mainCommittee "Total 4 Main Committees"
rename y1801b sameWorkPlace
label variable sameWorkPlace "1 for Independent Director's Workplace the same as Listed Company's Location, 2 for not, 3 for uncertain"
save CG_Ybasic_, replace
use board, clear
merge 1:1 stkcd reptdt using CG_Ybasic_
drop _merge
save board, replace
shell rename "E:\proj\busyBoard\processingData\FR_T4.dta" "roa.dta"
use roa, clear
rename accper reptdt
rename t40200 pm
label variable pm "Profit Margin"
rename t40401 roa1
label variable roa1 "Return on Asset 1: return / year end asset"
rename t40402 roa2
label variable roa2 "Return on Asset 2: return / averge asset 1"
rename t40403 roa3
label variable roa3 "Return on Asset 3: return / averge asset 2"
save roa, replace
shell rename "E:\proj\busyBoard\processingData\FR_T6.dta" "mb.dta"
use mb, clear
rename accper reptdt
rename t61501 mktValue1
label variable mktValue1 "Market Value 1"
rename t61502 mktValue2
label variable mktValue2 "Market Value 2"
rename t61601 mb1
label variable mb1 "Market to Book Ratio 1"
rename t61603 mb2
label variable mb2 "Market to Book Ratio 2"
save mb, replace
shell rename "E:\proj\busyBoard\processingData\FS_Combas.dta" "balanceSheet.dta"
use balanceSheet, clear
rename accper reptdt
rename a001219000 rd
label variable rd "R & D"
rename a001000000 asset
label variable asset "Total Asset"
rename a003000000 equity
label variable equity "Total Equity"
save balanceSheet, replace
shell rename "E:\proj\busyBoard\processingData\FS_Comins.dta" "income.dta"
use income, clear
rename accper reptdt
rename b001100000 revenue
label variable revenue "Revenue"
rename b001101000 optIncome
label variable optIncome "Operating Income"
rename b001212000 impair
label variable impair "Asset Impairment"
rename b002000000 profit
label variable profit "Profit"
save income, replace
shell rename "E:\proj\busyBoard\processingData\FS_Comscfi.dta" "cashflow.dta"
use cashflow, clear
rename accper reptdt
rename d000103000 depr
label variable depr "Depreciation"
save cashflow, replace
shell rename "E:\proj\busyBoard\processingData\FS_Combas1.dta" "intang.dta"
use intang, clear
rename accper reptdt
rename a001218000 intang
label variable intang "Intangible Asset"
save intang, replace
shell rename "E:\proj\busyBoard\processingData\TRD_Co.dta" "indID.dta"
shell rename "E:\proj\busyBoard\processingData\TRD_Co1.dta" "estbDate.dta"
use estbDate, clear
rename estbdt estbDate
label variable estbDate "Founded Date"
save estbDate, replace


***************************** Part 2: Manipulate And Get Tidy Data ******************************
* Generate each director's total cocurrent positions
use partTime, clear
gen temp = 1
bys stkcd reptdt name: egen totPT = sum(temp)
drop temp
label variable totPT "Total Cocurrent Position"
keep stkcd reptdt name totPT
duplicates drop
save totPt, replace

* Generate busyBoard dummy variable and average directorships variable
* Also generate total independent directors whose age are above 60
use director, replace
drop if substr(reptdt,1,3) == "199" | substr(reptdt,1,4) == "2000" 
drop edu positionTitle staTime endTime getPaid compensation bonus
merge 1:1 stkcd reptdt name using totPt
* Correct some typo in data manully, for example, the same guy is treated as two differnt people
* due to different case of English character in spelling
replace totPT = 15 in 117
replace totPT = 1 in 74073
replace totPT = 1 in 181002
replace totPT = 1 in 156556
replace totPT = 1 in 156581
replace totPT = 2 in 190412
drop if substr(reptdt,1,4) == "2013" | substr(reptdt,1,4) == "2014"
drop if _merge == 2 // The rest are those without name!!
drop _merge
replace totPT = 0 if totPT == .
replace totPT = totPT + 1
rename totPT totPost
label variable totPost "Total Position Holding" 
save director_V2, replace
keep if substr(positionID,1,2) == "12"
drop positionID position
gen isBusyDir3 = totPost >= 3
label variable isBusyDir3 "1 for busy director(positions holding > 3), 0 otherwise"
gen isBusyDir2 = totPost >= 2
label variable isBusyDir2 "1 for busy director(positions holding > 2), 0 otherwise"
gen isBusyDir4 = totPost >= 4
label variable isBusyDir4 "1 for busy director(positions holding > 4), 0 otherwise"
save indDir, replace
use board, clear
drop if substr(reptdt,1,3) == "199" | substr(reptdt,1,4) == "2000" | ///
	substr(reptdt,1,4) == "2013" | substr(reptdt,1,4) == "2014"
drop  annodt stkStr shhol shholRelated employee retire boardChairman ///
	genMan ChairGenSame totIndDir
merge 1:m stkcd reptdt using indDir
drop if _merge == 1 // Those are companies without independent directors
drop _merge
gen temp = 1
bys stkcd reptdt: egen indDirTot = sum(temp)
label variable indDirTot "Total Independent Directors"
drop temp
destring age, replace
gen ageOver60 = age >= 60
bys stkcd reptdt: egen over60 = sum(ageOver60)
bys stkcd reptdt: egen totBusyDir2 = sum(isBusyDir2)
bys stkcd reptdt: egen totBusyDir3 = sum(isBusyDir3)
bys stkcd reptdt: egen totBusyDir4 = sum(isBusyDir4)
gen busyBoard2 = totBusyDir2 / indDirTot >= 0.5
gen busyBoard3 = totBusyDir3 / indDirTot >= 0.5
gen busyBoard4 = totBusyDir4 / indDirTot >= 0.5
gen busyBoard2Per = totBusyDir2 / indDirTot
gen busyBoard3Per = totBusyDir3 / indDirTot
gen busyBoard4Per = totBusyDir4 / indDirTot
keep  stkcd reptdt totDir boardHolding supHolding exeHolding ///
	manHolding committee indDirTot busyBoard2 busyBoard3 busyBoard4 ///
	busyBoard2Per busyBoard3Per busyBoard4Per over60
duplicates drop
save board_V2, replace

* Generate Board Characteristics
*	Generate CEO/General Manager total directors
use board, clear
keep stkcd reptdt genMan
replace genMan = substr(genMan,1,length(genMan)-6) if strpos(genMan,"代理") //drop "代理"
replace genMan = substr(genMan,1,length(genMan)-5) if strpos(genMan,"(代)") //drop "代"
rename genMan name
*	Correct some typo
replace name = "邬昆华" in 1653
replace name = "李明" in 13775
replace name = "赵闻斌" in 20452
replace name = "于宏卫" in 4211
replace name = "李培忠" in 17012
merge 1:1 stkcd reptdt name using director_V2
drop if _merge == 2
keep stkcd reptdt totPost
rename totPost ceoTotPost
replace ceoTotPost = 1 if ceoTotPost == .
save ceoTotPost,replace
use board_V2,clear
merge 1:1 stkcd reptdt using ceoTotPost
keep if _merge == 3
drop _merge
save board_V2, replace

*	Generate other board characteristics
use board_V2, clear
destring totDir, replace
gen lnBoard = ln(totDir)
merge 1:1 stkcd reptdt using shares
keep if _merge == 3 // Those dropped are the companies not listing yet at there report date
drop _merge
destring boardHolding, replace
gen borHoldPer = boardHolding / shares * 100
destring manHolding, replace
gen manHoldPer = manHolding / shares * 100
gen indDirPer = indDirTot / totDir
save board_V2, replace
merge 1:1 stkcd reptdt using meeting
drop if _merge == 2
drop _merge
save board_V2, replace

* Generate firm characteristics
use balanceSheet, clear
drop if substr(reptdt,length(reptdt)-4,length(reptdt)) != "12-31"
replace rd = 0 if rd== .
merge 1:1 stkcd reptdt using income
drop if _merge == 2
drop _merge
merge 1:1 stkcd reptdt using cashflow
drop if _merge == 2
drop _merge
merge 1:1 stkcd reptdt using mb
drop if _merge == 2
drop _merge
merge 1:1 stkcd reptdt using roa
drop if _merge == 2
drop _merge
merge 1:1 stkcd reptdt using intang
drop if _merge == 2
drop _merge
merge m:1 stkcd using estbDate
drop if _merge == 2
drop _merge
gen date = date(reptdt,"YMD")
gen estDate = date(estbDate,"YMD")
gen year = year(date)
gen estYear = year(estDate)
xtset stkcd year
bys stkcd: gen saleGrowth = (revenue - L.revenue) / L.revenue
gen growthOpp = depr / revenue
gen intangAss = intang / asset
gen firmAge = year - estYear
rename pm ros
gen mb = mb1
replace mb = mb2 if mb == .
drop if substr(reptdt,1,3) == "199" | substr(reptdt,1,4) == "2000" | ///
	substr(reptdt,1,4) == "2013" | substr(reptdt,1,4) == "2014"
drop  estYear estDate date estbDate mktValue1 mktValue2 mb1 mb2
save firmChara, replace

* Get Tidy Data!!! Finally......
use board_V2, clear
merge 1:1 stkcd reptdt using firmChara
keep if _merge == 3
drop _merge
preserve
use csi300, clear
rename ConstituentCode stkcd
keep stkcd
destring stkcd, replace
save csiStk300,replace
restore
merge m:1 stkcd using csiStk300
drop if _merge == 2
replace _merge = 0 if _merge == 1
replace _merge = 1 if _merge == 3
rename _merge csi300
label drop _merge
preserve
use indID, clear
keep stkcd nnindcd nnindnme 
rename nnindcd indID
rename nnindnme indName
save indID1, replace
restore
merge m:1 stkcd using indID1
keep if _merge == 3
drop _merge
label variable over60 "Total Directors whose age is above 60"
label variable busyBoard2 "Busy Board Dummy (Threshold:2)"
label variable busyBoard3 "Busy Board Dummy (Threshold:3)"
label variable busyBoard4 "Busy Board Dummy (Threshold:4)"
label variable busyBoard2Per "Busy Director Percentage (Threshold:2)"
label variable busyBoard3Per "Busy Director Percentage (Threshold:3)"
label variable busyBoard4Per "Busy Director Percentage (Threshold:4)"
label variable lnBoard "ln(Board Size)"
label variable borHoldPer "Board Share Holding (%)"
label variable manHoldPer "Management Share Holding (%)"
label variable indDirPer "Independent Director (%)"
label variable saleGrowth "Sales Growth"
label variable growthOpp "Growth Opportunity"
label variable intangAss "Intangible Asset / Total Asset"
label variable firmAge "Firm Age"
label variable mb "Market to Book Ratio"
label variable indID "Industry ID"
label variable indName "Industry Name"
label variable csi300 "CSI300 Dummy"
label variable year "Report Year"
label variable stkcd "Stock ID"
drop indcd
move year reptdt
save tidy, replace


************************** Part 3: Descriptive Analysis and Regression **************************
cd $wd
mkdir tidyData
cd tidyData
shell copy "E:\proj\busyBoard\processingData\tidy.dta" "E:\proj\busyBoard\tidyData\"
use tidy, clear
drop if strpos(indID,"J") // Drop financial sector companies
xtset stkcd year
char _dta[omit] "prevalent"
xi i.year i.indID
gen lnAsset = ln(asset)
label variable lnAsset "ln(Asset)"
gen lnMeetings = ln(meetings)
label variable lnMeetings "ln(Meetings)"
gen busyBoard2CSI300 = busyBoard2 * csi300
gen busyBoard3CSI300 = busyBoard3 * csi300
gen busyBoard4CSI300 = busyBoard4 * csi300
label variable busyBoard2CSI300 "Busy Board Dummy 2 * CSI 300"
label variable busyBoard3CSI300 "Busy Board Dummy 3 * CSI 300"
label variable busyBoard4CSI300 "Busy Board Dummy 4 * CSI 300"
gen busyBoard2PerCSI300 = busyBoard2Per * csi300
gen busyBoard3PerCSI300 = busyBoard3Per * csi300
gen busyBoard4PerCSI300 = busyBoard4Per * csi300
label variable busyBoard2PerCSI300 "Busy Board (%) 2 * CSI 300"
label variable busyBoard3PerCSI300 "Busy Board (%) 3 * CSI 300"
label variable busyBoard4PerCSI300 "Busy Board (%) 4 * CSI 300"
gen BB2lag3 = L3.busyBoard2
gen BB3lag3 = L3.busyBoard3
gen BB4lag3 = L3.busyBoard4
label variable BB2lag3 "Busy Board Dummy 2_t-3"
label variable BB3lag3 "Busy Board Dummy 3_t-3"
label variable BB4lag3 "Busy Board Dummy 4_t-3"
gen BBPer2lag3 = L3.busyBoard2Per
gen BBPer3lag3 = L3.busyBoard3Per
gen BBPer4lag3 = L3.busyBoard4Per
label variable BBPer2lag3 "Busy Board (%) 2_t-3"
label variable BBPer3lag3 "Busy Board (%) 3_t-3"
label variable BBPer4lag3 "Busy Board (%) 4_t-3"
gen BB2lag3CSI300 = BB2lag3 * csi300
gen BB3lag3CSI300 = BB3lag3 * csi300
gen BB4lag3CSI300 = BB4lag3 * csi300
label variable BB2lag3CSI300 "Busy Board Dummy 2_t-3 * CSI 300"
label variable BB3lag3CSI300 "Busy Board Dummy 3_t-3 * CSI 300"
label variable BB4lag3CSI300 "Busy Board Dummy 4_t-3 * CSI 300"
gen BBPer2lag3CSI300 = BBPer2lag3 * csi300
gen BBPer3lag3CSI300 = BBPer3lag3 * csi300
gen BBPer4lag3CSI300 = BBPer4lag3 * csi300
label variable BBPer2lag3CSI300 "Busy Board (%) 2_t-3 * CSI 300"
label variable BBPer3lag3CSI300 "Busy Board (%) 3_t-3 * CSI 300"
label variable BBPer4lag3CSI300 "Busy Board (%) 4_t-3 * CSI 300"
gen over60CSI300 = over60 * csi300
label variable over60CSI300 "Directors above 60"
save spec, replace

* Basic Specification
eststo clear
eststo: xtivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard  indDirPer  manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3 busyBoard3CSI300 = BB3lag3 over60  ///
		BB3lag3CSI300 over60CSI300), fe robust first
eststo: xtivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros  intangAss firmAge ceoTotPost ///
		lnBoard  indDirPer  manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3 busyBoard3CSI300 = BB3lag3 over60  ///
		BB3lag3CSI300 over60CSI300), fe robust first
reg mb busyBoard3 lnAsset growthOpp saleGrowth L.saleGrowth ros intangAss  firmAge ///
		ceoTotPost L.mb L2.mb lnBoard  indDirPer  manHoldPer borHoldPer ///
		committee lnMeetings _Iyear* _IindID* , robust		
esttab using table.csv ,star(* 0.1 ** 0.05 *** 0.01) ar2 label ///
	drop(_Iyear* _IindID*) se order( busyBoard3 busyBoard3CSI300 BB3lag3 ///
	over60 BB3Lag3CSI300 over60CSI300 lnAsset ros growthOpp ///
	saleGrowth L.saleGrowth L.mb L2.mb L.ros L.ros intangAss ///
	firmAge ceoTotPost lnBoard indDirPer manHoldPer ///
	borHoldPer committee lnMeetings)b(%9.2f) wide replace 

* Alternative Measure of Busy Board
eststo clear
* Threshold: 2
*	Dummy
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard2 busyBoard2CSI300 = BB2lag3 over60  ///
		BB2Lag3CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard2 busyBoard2CSI300 = BB2lag3 over60  ///
		BB2Lag3CSI300 over60CSI300), fe robust
*	Percentage
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard2Per busyBoard2PerCSI300 = BBPer2lag3 over60  ///
		BBPer2Lag3CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard2Per busyBoard2PerCSI300 = BBPer2lag3 over60  ///
		BBPer2Lag3CSI300 over60CSI300), fe robust
* Threshold: 3
*	Dummy
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3 busyBoard3CSI300 = BB3lag3 over60  ///
		BB3Lag3CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3 busyBoard3CSI300 = BB3lag3 over60  ///
		BB3Lag3CSI300 over60CSI300), fe robust
*	Percentage
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3Per busyBoard3PerCSI300 = BBPer3lag3 over60  ///
		BBPer3Lag3CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard3Per busyBoard3PerCSI300 = BBPer3lag3 over60  ///
		BBPer3Lag3CSI300 over60CSI300), fe robust
* Threshold: 4
*	Dummy
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard4 busyBoard4CSI300 = BB4lag3 over60  ///
		BB4Lag3CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard4 busyBoard4CSI300 = BB4lag3 over60  ///
		BB4Lag3CSI300 over60CSI300), fe robust
*	Percentage
eststo: xitivreg2 mb lnAsset ros growthOpp saleGrowth L.saleGrowth ///
		L.mb L2.mb  intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard4Per busyBoard4PerCSI300 = BBPer4lag3 over60  ///
		BBPer2Lag4CSI300 over60CSI300), fe robust
eststo: xitivreg2 ros lnAsset growthOpp saleGrowth L.saleGrowth ///
		L.ros L2.ros intangAss firmAge ceoTotPost ///
		lnBoard indDirPer manHoldPer borHoldPer ///
		committee lnMeetings  _Iyear* _IindID* ///
		(busyBoard4Per busyBoard4PerCSI300 = BBPer4lag3 over60  ///
		BBPer4Lag3CSI300 over60CSI300), fe robust
esttab using table_mul_ROS.csv ,star(* 0.1 ** 0.05 *** 0.01) ar2 label ///
	keep(busyBoard2 busyBoard3 busyBoard4 busyBoard2CSI300 ///
	busyBoardCSI300 busyBoard4CSI300 ///
	busyBoard2Per busyBoard3Per busyBoard4Per ///
	busyBoard2PerCSI300 busyBoard3PerCSI300 busyBoard4PerCSI300) ///
	order(busyBoard2 busyBoard2CSI300 busyBoard2Per busyBoard2PerCSI300 /// 
	busyBoard3 busyBoard3CSI300 busyBoard3Per busyBoard3PerCSI300 ///
	busyBoard4 busyBoard4CSI300 busyBoard4Per busyBoard4PerCSI300) ///
	b(%9.2f) wide replace se
