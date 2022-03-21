*--------------------------------------------------------------------------
* SCRIPT: 1_clean_data.do
* PURPOSE: cleans the  experimental data and generates additional variables
*--------------------------------------------------------------------------
*Import excel dataset
import excel using "$working_ANALYSIS/data/migration_survey_experiment.xlsx" , firstrow clear



*--------------------------------------------------------------------------
* Cleaing & Labelling
*--------------------------------------------------------------------------
drop ecoacceptance envccacceptance polacceptance  envnccacceptance

label var acceptance "Would you agree that this person can legally migrate to Austria?"
label define one_eight 1 "1 'completely against'" 2 "2 'strongly against'" 3 "3 'against'" 4 "4 'rather against'" 5 "5 'rather support'" 6 "6 'support'" 7 "7 'strongly support'" 8 "8 'completely support'",replace
label values acceptance one_eight

label var wtp "Willingness to pay in order that 10% more migrants can move to Austria"

label var wta "Willingness to accept 10% more migrants in Austria"

label var sure "How sure are you about the amount you stated for wtp/wta?"

label define yes_no 0 "no" 1 "yes"

rename reffamily unify_fam
label var unify_fam "Would you support migration of his family, once he found a job?"
label values unify_fam one_eight

rename topic interest
label var interest "Interest in migration topic"
label define interest1 0 "not interested at all" 1 "somewhat interested" 2 "very interested", replace
label values interest interest1


rename conflictcause legit_conflict
label var legit_conflict "Is conflict a legitimate reason for asylum (Geneva Convention)?"
label values  legit_conflict yes_no

rename ecocause legit_eco
label var legit_eco "Are economic problems a legitimate reason for asylum (Geneva Convention)?"
label values  legit_eco yes_no

rename envcause legit_env
label var legit_env "Is environmental degration a legitimate reason for asylum (Geneva Convention)?"
label values  legit_env yes_no


foreach var of varlist factor_* {
	label var `var' "Important factors for migrants if they want to live in Austria."
	label values `var' yes_no
	}

rename work_shortage help_economy
label var help_economy "Do immigrants take jobs from Austrians?"
label define steal1 2 "They help the economy" 1 "They steal jobs" 0 "Don't know", replace
label values help_economy steal1

rename give_take immigrants_costly
label var immigrants_costly "Do immigrants cost the welfare state more than they give?"
label define costly1 1 "cost more" 2 "contribute more" 0 "Don't know", replace
label values immigrants_costly costly1

label var crime_rate "Scale on crime rate changes due to migration from increases strongly to reduces strongly"
label define crime1 4 "strong increase" 3 "increase slightly" 2 "same" 1 "decrease slightly" 0 "decrease strongly",replace
label values crime_rate crime1

rename appeals_eu pleas_abroad
label var pleas_abroad "Asylum pleas should be already done abroad, outside the EU."
label define agree_scale 4 "agree" 3 "agree slightly" 2 "don't care" 1 "disagree slightly" 0 "disagree",replace
label values pleas_abroad agree_scale

label define surr_scale 0 "very low" 1 "low" 2 "moderate" 3 "high" 4 "very high", replace
label var surr_foreigner "Share of foreigners in neighborhood on a scale from very high to very low"
label values surr_foreigner surr_scale
label var surr_crime "Crimes in neighborhood on a scale from very high to very low"
label values surr_crime surr_scale
label var surr_poverty "Poverty rate in neighborhood on a scale from very high to very low"
label values surr_poverty surr_scale

label var norms_values "All people in a country should share the same norms and values"
label values norms_values agree_scale

rename clique foreign_friends
label var foreign_friends "Do you have friends of different ethnicitiy, religion, etc.?"
label define foreign1 0 "none"  1 "a few" 2 "many", replace
label values foreign_friends foreign1


label var party "Which political party would you vote for?"
replace party=5 if party==6
replace party=6 if party==7
replace party=7 if party==8
replace party=8 if party==9
replace party=9 if party==10
replace party=10 if party==11
label define party1 1 "SPÖ" 2 "ÖVP" 3 "FPÖ" 4 "BZÖ" 5 "Die Grünen" 6 "Team Stronach" 7 "NEOs" 8 "KPÖ" 9 "Piratenpartei" 10 "Other"
label values party party1

label var religion "Are you part of a religious community?"
label values religion yes_no

label var mess "How often do you go to prayer?"
label define mess1	3 "frequently" 2 "sometimes" 1 "rarely" 0 "never", replace
label values mess mess1

label var marital "Marital status"
label define marital1 1 "single" 2 "in a relationship" 3 "married", replace
label values marital marital1

rename gender female
replace female=0 if female==1
replace female=1 if female==2
label var female "Respondents gender, 1 if female"
label define gender 0 "male" 1 "female"
label values female gender

label var age "Respondents age in years"

label var study "Subject respondent studies"

label var origin "Country where participant is from."


/*
#############################
GENERATE important variables
#############################
*/

*treatment identifier

gen treatment=1 if randnumber==2
replace treatment=4 if randnumber==1
replace treatment=2 if randnumber==3 | randnumber==4
replace treatment=3 if randnumber==5 | randnumber==6
lab def t_lab 1 "CONFLICT" 4 "ECON" 2 "ENV GLOBAL" 3 "ENV LOCAL"
label var treatment "Treatment"
lab val treatment t_lab

tabulate treatment, gen(t_)

// Treatment dummies
gen econ = 0 
replace econ = 1 if treatment==1
label variable eco "Treatment economic reason for migration"

gen pol = 0 
replace pol = 1 if treatment==2
label variable pol "Treatment  political reason for miration"

gen env_cc = 0 
replace env_cc = 1 if treatment==3
label variable env_cc "Treatment environmental reason due to CC for migration"

gen env_self = 0 
replace env_self = 1 if treatment==4
label variable env_self "Treatment environmental reason self-imposed for migration"


// Polarization in acceptance levels
gen imm_opinion=.
replace imm_opinion=1 if acceptance < 4
replace imm_opinion=2 if acceptance==4 
replace imm_opinion=3 if acceptance==5
replace imm_opinion=4 if acceptance > 5

lab def str_opinion 1 "<4 'against' " 2 "4='rather against'" 3 "5='rather support'" 4 ">5 'support' ", replace
lab val imm_opinion str_opinion
tab imm_opinion

lab var acceptance "Acceptance Level"



// OTHER DUMMIES
gen accept=0
replace accept=1 if acceptance > 4
lab var accept "Takes the value of one if the respondent would accept the migrant, 0 if not"

gen accept2=. if imm_opinion==2 | imm_opinion==3
replace accept2=0 if imm_opinion==1
replace accept2=1 if imm_opinion==4
lab var accept2 "Binary acceptance variable without incl. undecided respondents"

gen incomplete=0
replace incomplete=1 if acceptance==.
lab def inco 0 "complete" 1 "incomplete"
lab val incomplete inco

*binary acceptance
generate h_acc=0 if acceptance < 5
replace h_acc=1 if acceptance >=5
replace h_acc=. if incomplete==1

gen single = 0
replace single = 1 if marital ==1
label var single "1 if respondent is single, 0 otherwise"
label values single yes_no

gen austrian = 0
replace austrian = 1 if origin=="AUT"
gen german = 0
replace german = 1 if origin=="GER"
gen italian = 0
replace italian = 1 if origin=="ITA"
gen origin_other = 1
replace origin_other = 0 if origin=="AUT" | origin=="GER" | origin=="ITA"

// PCA for expectations about migrants integrating into society [1/0] Questions
gen factor_norm=0
replace factor_norm=1 if norms_values > 2
lab var factor_norm "All people in a country should share the same norms and values."

global norm factor_edu factor_lang factor_cult factor_age factor_work factor_rel factor_skin
alpha $norm
pca factor_norm factor_edu factor_lang factor_cult factor_age factor_work factor_rel factor_skin, comp(1)
estat loadings
predict pc1, score
estat kmo // middling, kmo=0.74 could use PCA or simmple index
sum pc1
gen pca_factors=(pc1 -r(min))/(r(max)-r(min))
label variable pca_factors "PCA: Important factors for immigrants that want to live in Austria"

bysort treatment: sum pca_factors

gen index_attributes = (factor_norm + factor_edu + factor_lang + factor_cult + factor_age + factor_work + factor_rel + factor_skin)
label var index_attributes "Index: Important attributes of immigrants"

// PCA for neihborhood
pwcorr surr_foreigner surr_crime surr_poverty, sig
pca surr_foreigner surr_crime surr_poverty,mineigen(1) comp(3)
estat loadings
predict pc2, score
estat kmo // mediocre, kmo=0.62, we should rather not use the PCA index
sum pc2
gen pca_surr=(pc2 -r(min))/(r(max)-r(min))
label variable pca_surr "PCA: Foreigners, crime and poverty in neighborhood"
bysort treatment: sum pca_surr

gen sur_for= surr_foreigner+1
gen sur_cri= surr_crime+1
gen sur_pov= surr_poverty+1

egen index_surr= rowmean(sur_for sur_cri sur_pov)
label var index_surr "Index: Neighborhood - crimes, poverty and foreigners"
sum index_surr
gen std_surr=(index_surr -r(min))/(r(max)-r(min))
bysort treatment: sum std_surr


// PCA, simple additive index for perceived impacts by immigrants: tax burden, steal jobs and increase crime
gen steal_jobs = 0 if help_economy!=.
replace steal_jobs =1 if help_economy==1
label var steal_jobs "Dummy: Immigrants steal jobs"

gen tax_burden = 0 if immigrants_costly!=.
replace tax_burden = 1 if immigrants_costly==1
label var tax_burden "Dummy: Immigrants cost the welfare state"
lab def tax_lab 1 "Cost more" 0 "Contribute more", replace
lab val tax_burden tax_lab

gen increase_crime = 0 if crime_rate!=.
replace increase_crime = 1 if crime_rate >2
lab var increase_crime "Dummy: Migration increases crime rate"


global perceived_impacts steal_jobs tax_burden crime_rate
pwcorr $perceived_impacts
alpha $perceived_impacts
pca $perceived_impacts, comp(1)
estat loadings
predict immigrants_impacts, score
estat kmo // middling, kmo=0.64 could be used 
sum immigrants_impacts



// dummy for knowledge of Geneva Refugee Convention
gen geneva=1
replace geneva=0 if treatment==1 & legit_conflict==0
replace geneva=0 if treatment==2 & legit_eco==1
replace geneva=0 if treatment==3 & legit_env==1
replace geneva=0 if treatment==4 & legit_env==1
label var geneva "Dummy: Knowledge of the geneva refugee convention of respective treatment"
lab def know1 0 "No" 1 "Yes", replace
lab val geneva know1

gen knowledge=0
replace knowledge=1 if legit_conflict==1 & legit_eco==0 & legit_env==0
label var knowledge "Dummy: Knowledge of the geneva refugee convention"
lab val knowledge know1

// Other variables
gen age_sq = age*age

gen never_mess=0
replace never_mess=1 if mess==0
lab var never_mess "Dummy: Never goes to mess"

gen diff_friends=0
replace diff_friends=1 if foreign_friends > 0
lab var diff_friends "Dummy: Friends from different ethnicity or religion"

gen high_interest=0
replace high_interest=1 if interest==2
lab var high_interest "Dummy: Very interested in migration topic"
gen legit_all = 0
replace legit_all = 1 if legit_conflict==1 & legit_eco==1 & legit_env==1
label var legit_all "1 if respondents think all migrants can apply for asylum"

gen center_voter = 0
replace center_voter = 1 if party==1 | party==2 | party==7
label var center_voter "1 if respondent would vote for either SPÖ or ÖVP"

gen left_voter = 0
replace left_voter = 1 if party==5 | party==9 | party==8
label var left_voter "1 if participant voted for 'die Grünen'"

gen right_voter = 0
replace right_voter = 1 if party==3 | party==4 | party==6
label var right_voter "1 if respondent would vote for the Freedom party of Austria"

gen no_voter = 0
replace no_voter = 1 if party==10
label var no_voter "1 if no party preference"

gen asylum_abroad = 0
replace asylum_abroad = 1 if pleas_abroad > 2
lab var asylum_abroad "Dummy: Asylum pleas should be made outside the EU"


label define party1 1 "SPÖ" 2 "ÖVP" 3 "FPÖ" 4 "BZÖ" 5 "Die Grünen" 6 "Team Stronach" 7 "NEOs" 8 "KPÖ" 9 "Piratenpartei" 10 "Other", replace

*party identifier
gen party_affiliation=.
replace party_affiliation=1 if left_voter==1
replace party_affiliation=2 if center_voter==1
replace party_affiliation=3 if right_voter==1
replace party_affiliation=4 if no_voter==1
label def pa 1 "Left voter" 2 "Center voter" 3 "Right voter" 4 "No voter"
lab val party_affiliation pa

*treatment interactions 
gen t2_right = t_2*right_voter
gen t3_right = t_3*right_voter
gen t4_right = t_4*right_voter
gen t2_female = t_2*female
gen t3_female = t_3*female
gen t4_female = t_4*female


*more labeling
label var female "Female"
label var age "Age"
label var religion "Dummy: Religious affiliation"
label var single "Dummy: Single"
label var left_voter "Dummy: Left voter"
label var right_voter "Dummy: Right voter"
label var center_voter "Dummy: Center voter"
label var no_voter "Dummy: No party preference"

save "$working_ANALYSIS/processed/migration_clean.dta", replace








** EOF
