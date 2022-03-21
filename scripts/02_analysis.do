*--------------------------------------------------------------------
* SCRIPT: 02_analysis.do
* PURPOSE: replicates all tables and figures and saves the results
*--------------------------------------------------------------------
*--------------------------------------------------
* AUTHOR GUIDELINES - Regional Environmental Change:
* The figures should be 84 mm, 129 mm, or 174 mm wide and not higher than 234 mm.

/* (1) MAIN MANUSCRIPT
	- Figure 1: Acceptance by treatment and polarization
	- TABLE 2: Overall determinants of acceptance levels with POL as reference group
	- TABLE 3: HETEROGENEOUS TREATMENT EFFECTS
	(2) SUPPLEMENTARY MATERIALS
*/
*--------------------------------------------------
use "$working_ANALYSIS/processed/migration_clean.dta", replace



*drop incompletely filled out responses
*Figure S1.	Attrition across treatments
catplot incomplete, recast(bar) b1title("") over(treatment) vertical asyvars yla(0(50)300) legend(pos(6) ring(1) row(1)) ytitle("Frequency") yla(,nogrid) blabel(bar, pos(outside) format(%4.0f)) xsize(`=8.4/2.54') ysize(`=6/2.54')
gr save "$working_ANALYSIS/results/intermediate/FigureS1.gph", replace
gr export "$working_ANALYSIS/results/figures/FigureS1.tif", replace width(4000)
kwallis incomplete, by(treatment)
*drop all observations where the participants did not complete the survey
drop if incomplete==1




*------------------------------
* (1) MAIN MANUSCRIPT
*------------------------------
*define globals
global treatments t_2 t_3 t_4
global socio_economic female single age religion diff_friends index_surr
global polit left_voter right_voter no_voter
global impacts steal_jobs increase_crime tax_burden index_attributes asylum_abroad 
	  	

*Fig 1.	Average acceptance and polarization across treatments
bysort treatment: su acceptance, detail
*Panel A: ATE
cibar acceptance, over1(treatment)  bargap(20) barlabel(on) blfmt(%5.1f) blpos(10) blgap(0.03) graphopts(xsize(2.5) ysize(2)  legend(ring (1) pos(6) rows(2)) yla(1(1)8, nogrid) xla(, nogrid)  title("{bf:a} Main treatment effects")  ytitle("Acceptance Level", )) ciopts(lcolor(black) lpattern(dash)) 
gr save "$working_ANALYSIS/results/intermediate/Figure1a.gph", replace

* H0: NO signficant differences across treatments
reg acceptance i.treatment, vce(robust)
* reject, env force and POL significantly higher

*H1: legal status matters?
ttest acceptance if treatment==1 | treatment==3, by(treatment)
ranksum acceptance if treatment==1 | treatment==3, by(treatment)
*no sign differnece between ENV FORCED and POL p=0.8), legal status seems not to be the main driver of acceptance

*H2: responsibility matters
ttest acceptance if treatment==3 | treatment==4, by(treatment)
ranksum acceptance if treatment==3 | treatment==4, by(treatment)

*H3: Voluntariness matters?
ttest acceptance if treatment==2 | treatment==4, by(treatment)
ranksum acceptance if treatment==2 | treatment==4, by(treatment)


*Panel B: Distribution by treatment
mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%") 
catplot imm_opinion, over(treatment) asyvars stack title("{bf:b} Polarization") yla(`pctlabel', nogrid) percent(treatment) legend(pos(6) ring(1) rows(2))  blabel(bar, format(%9.0f) pos(center)) ytitle("") l1title("")  b1title("")  xsize(`=8.4/2.54') ysize(`=6/2.54')
gr save "$working_ANALYSIS/results/intermediate/Figure1b.gph", replace

gr combine "$working_ANALYSIS/results/intermediate/Figure1a.gph" "$working_ANALYSIS/results/intermediate/Figure1b.gph", rows(1)  xsize(3.465) ysize(2) iscale(1.1)
gr save "$working_ANALYSIS/results/intermediate/Figure1.gph", replace
gr export "$working_ANALYSIS/results/figures/Figure1.tif", replace width(4000)


* differences between treatments
kwallis imm_opinion, by(treatment)
tab imm_opinion if treatment > 1
* Does knowledge of Geneva Convention drive acceptance levels?
bysort treatment: tab geneva
* Only one respondent in POL did not know that the person had the right to apply for asylum

ranksum acceptance if treatment==1, by(knowledge)
ranksum acceptance if treatment==2, by(knowledge)
ranksum acceptance if treatment==3, by(knowledge)
ttest acceptance if treatment==3, by(knowledge)
* in ENV FORCED p<0.05 --> lower acceptance by 0.5 points on average
* among people who know the geneva convention
ranksum acceptance if treatment==4, by(knowledge)



*Table 1.	Determinants of immmigration acceptance
*Without controls (replicating T-tests)
reg acceptance $treatments, vce(robust) 
outreg2 using "$working_ANALYSIS/results/tables/Table1", addstat("Adjusted R-squared", e(r2_a)) adec(2) dec(2) word replace

* Socio-demographics
reg acceptance $treatments $socio_economic, vce(robust) 
testparm $socio_economic
local F1 = r(p)
outreg2 using "$working_ANALYSIS/results/tables/Table1", addstat("Adjusted R-squared", e(r2_a), "F-test: Socio-demographics", `F1') adec(2) dec(2) word append

* Attitudes towards immigration
reg acceptance $treatments $socio_economic $impacts, vce(robust) 
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
outreg2 using "$working_ANALYSIS/results/tables/Table1",  addstat("Adjusted R-squared", e(r2_a), "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2') adec(2) dec(2) word append

* Political orientation: Party preferences
reg acceptance $treatments $socio_economic $impacts $polit, vce(robust) 
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
testparm $polit
local F3 = r(p)
outreg2 using "$working_ANALYSIS/results/tables/Table1", addstat("Adjusted R-squared", e(r2_a), "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2', "F-Test: Party preferences", `F3') adec(2) dec(2) word append


*Table 2.	Heterogeneous treatment effects by gender and party preference
global socio_demographic single age religion diff_friends index_surr
global interactions1 t_2 t_3 t_4 female t2_female t3_female t4_female
global interactions2 t_2 t_3 t_4 right_voter t2_right t3_right t4_right
global polit2 left_voter no_voter

*Gender
reg acceptance $interactions1 $socio_demographic $impacts $polit, vce(robust) 
testparm t_2 female t2_female
local F1 = r(p)
testparm t_3 female t3_female
local F2 = r(p)
testparm t_4 female t4_female
local F3 = r(p)
outreg2 using "$working_ANALYSIS/results/tables/Table2", drop($socio_demographic $impacts $polit) addstat("Adjusted R-squared", e(r2_a), "F-Test: Interaction ENV GLOBAL", `F1', "F-Test: Interaction ENBV LOCAL ", `F2', "F-Test: Interaction ECON", `F3') adec(2) dec(2) word replace

*Party preference: Right-wing voter
reg acceptance $interactions2 $socio_economic $impacts $polit2, vce(robust) 
testparm t_2 right_voter t2_right
local F1 = r(p)
testparm t_3 right_voter t3_right
local F2 = r(p)
testparm t_4 right_voter t4_right
local F3 = r(p)
outreg2 using "$working_ANALYSIS/results/tables/Table2", drop($socio_economic $impacts $polit2) addstat("Adjusted R-squared", e(r2_a), "F-Test: Interaction ENV GLOBAL", `F1', "F-Test: Interaction ENBV LOCAL ", `F2', "F-Test: Interaction ECON", `F3')  adec(2) dec(2) word append




*------------------------------
* (2) SUPPLEMENTARY MATERIALS
*------------------------------
*define globals
global overview acceptance female single age religion diff_friends index_surr austrian german italian origin_other center_voter left_voter right_voter no_voter index_attributes asylum_abroad steal_jobs increase_crime tax_burden knowledge legit_conflict legit_eco legit_env high_interest
global balance female single age religion diff_friends index_surr austrian german italian origin_other center_voter left_voter right_voter no_voter knowledge high_interest
global opinions steal_jobs increase_crime tax_burden index_attributes index_surr asylum_abroad


*TABLE S1:  Summary statistics
estpost tabstat $overview, statistics(mean sd min max) columns(statistics)
esttab . using "$working_ANALYSIS/results/tables/TableS1.rtf" , replace cells("mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) min(fmt(0)) max(fmt(0))")  not nostar unstack nomtitle nonumber nonote label 
 
*TABLE S2: Treatment balance
iebaltab $balance, grpvar(treatment) onerow rowvarlabels format(%9.2f) stdev ftest fmissok tblnonote save("$working_ANALYSIS/results/tables/TablesS2.xlsx") replace

*Figure S2.	Acceptance by perceived welfare impacts
cibar acceptance, over1(tax_burden) over2( treatment) gap(30) barlabel(on) blfmt(%5.1f) blpos(10) blgap(0.03) graphopts(xsize(`=8.4/2.54') ysize(`=6/2.54')  legend(ring (1) pos(6) rows(1))  yla(1(1)8, nogrid) xla(, nogrid) ytitle("Average acceptance")) ciopts(lcolor(gs3) lpattern(dash))
gr save "$working_ANALYSIS/results/intermediate/figureS2.gph", replace
gr export "$working_ANALYSIS/results/figures/figureS2.tif", replace width(4000)

ttest acceptance, by(tax_burden)
* M_more=5.6 M_less=4.2 SE_diff=0.14 t_684=9.95 p=0.00
ttest acceptance if treatment==2, by(tax_burden)
ranksum acceptance if treatment==1 , by(tax_burden)
ttest acceptance if treatment==1 , by(tax_burden)
ranksum acceptance if treatment==2 , by(tax_burden)
ttest acceptance if treatment==2 , by(tax_burden)
ranksum acceptance if treatment==3 , by(tax_burden)
ttest acceptance if treatment==3 , by(tax_burden)
ranksum acceptance if treatment==4 , by(tax_burden)
ttest acceptance if treatment==4 , by(tax_burden)


*Figure S3.	Heterogeneous treatment effects by knowledge of the Geneva convention
cibar acceptance, over1(geneva) over2( treatment) gap(30) barlabel(on) blfmt(%5.1f) blpos(10) blgap(0.03) graphopts(xsize(`=8.4/2.54') ysize(`=6/2.54')  legend(ring (1) pos(6) rows(1))  yla(1(1)8, nogrid) xla(, nogrid) ytitle("Average acceptance")) ciopts(lcolor(gs3) lpattern(dash))
gr save "$working_ANALYSIS/results/intermediate/figureS3.gph", replace
gr export "$working_ANALYSIS/results/figures/figureS3.tif", replace width(4000)

ranksum acceptance if treatment==1, by(geneva)
ranksum acceptance if treatment==2, by(geneva)
ranksum acceptance if treatment==3, by(geneva)
ranksum acceptance if treatment==4, by(geneva)


*Table S3.	Odds ratios of acceptance levels
* no controls
ologit acceptance $treatments, vce(robust) or
local R2= e(r2_p)
outreg2 using "$working_ANALYSIS/results/tables/TableS3", addstat("Pseudo R-squared", `R2') adec(2) dec(2) word replace

*socio-demographics
ologit acceptance $treatments $socio_economic, vce(robust) or
testparm $socio_economic
local F1 = r(p)
local R2= e(r2_p)
outreg2 using "$working_ANALYSIS/results/tables/TableS3", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1') adec(2) dec(2) word append

* Attitudes towards immigration
ologit acceptance $treatments $socio_economic $impacts, vce(robust) or
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
local R2= e(r2_p)
outreg2 using "$working_ANALYSIS/results/tables/TableS3", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2') adec(2) dec(2) word append

* Political orientation: Party preferences
ologit acceptance $treatments $socio_economic $impacts $polit, vce(robust) or
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
testparm $polit
local F3 = r(p)
local R2= e(r2_p)
outreg2 using "$working_ANALYSIS/results/tables/TableS3", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2', "F-Test: Party preferences", `F3') adec(2) dec(2) word append


*Table S4.	Binary– Main treatment effects of acceptance rate
* no controls
probit h_acc $treatments, vce(robust)
local R2= e(r2_p)
margins, dydx(*) post
outreg2 using "$working_ANALYSIS/results/tables/TableS4", addstat("Pseudo R-squared", `R2') adec(2) dec(2) word replace

*socio-demographics
probit h_acc  $treatments $socio_economic, vce(robust)
local R2= e(r2_p)
testparm $socio_economic
local F1 = r(p)
margins, dydx(*) post
outreg2 using "$working_ANALYSIS/results/tables/TableS4", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1') adec(2) dec(2) word append

* Attitudes towards immigration
probit h_acc $treatments $socio_economic $impacts, vce(robust)
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
local R2= e(r2_p)
margins, dydx(*) post
outreg2 using "$working_ANALYSIS/results/tables/TableS4", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2') adec(2) dec(2) word append


* Political orientation: Party preferences
probit h_acc $treatments $socio_economic $impacts $polit, vce(robust)
testparm $socio_economic
local F1 = r(p)
testparm $impacts
local F2 = r(p)
testparm $polit
local F3 = r(p)
local R2= e(r2_p)
margins, dydx(*) post
outreg2 using "$working_ANALYSIS/results/tables/TableS4", addstat("Pseudo R-squared", `R2', "F-Test: Socio-demographics", `F1', "F-Test: Attitudes", `F2', "F-Test: Party preferences", `F3') adec(2) dec(2) word append




*Table S5.	Immigration attitudes by political orientation
iebaltab $opinions, grpvar(party_affiliation) onerow rowvarlabels format(%9.2f) stdev ftest fmissok tblnonote save("$working_ANALYSIS/results/tables/tableS5.xlsx") replace


*Table S6.	Comparison of respondents’ party preferences to real election results
*created in word based on data from: https://bmi.gv.at/412/Nationalratswahlen/Nationalratswahl_2017/start.aspx




** EOF