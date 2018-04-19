* Encoding: UTF-8.

* Muuttujien uudelleenkoodaaminen

MISSING VALUES    k7a to k7k (8).

RECODE k7a to k7k (1=5) (2=4) (3=3) (4=2) (5=1).

RECODE    k18a (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4) (8=3) (9=2) (10=1) into k18a_rev.
VALUE LABELS    
k18a
1 'Hyväosaisimmat'
10 'Huono-osaisimmat'.
EXECUTE.    

MISSING VALUES    k8a to k8d (8).

RECODE bv1 (1=5) (2=4) (4=4) (5=5) (6=4) (19=1) (20=5) (21=SYSMIS) (7 thru 9=5) (10 thru 12=3) (13 thru 
    16=4) (17 thru 18=2) INTO laanit.
VARIABLE LABELS  laanit 'Läänit'.
EXECUTE.

VALUE LABELS 
laanit
1 'Lapin lääni'
2 'Oulun lääni'
3 'Itä-Suomen lääni'
4 'Länsi-Suomen lääni'
5 'Etelä-Suomen lääni'.
EXECUTE.

RECODE bv1 (1=1) (2=1) (4=1) (5=1) (6=1) (10=1) (11=2) (19=1) (20=1) (21=SYSMIS) (7 thru 9=1) (12=2) (13 thru 
    18=2) INTO pahkina.
VARIABLE LABELS  pahkina 'Pähkinäsaaren raja'.
EXECUTE.

VALUE LABELS 
pahkina
1 'Etelä'
2 'Pohjoinen'.
EXECUTE.

RECODE bv1 (1=1) (2=2) (4=2) (5 thru 6=3) (7 thru 9=1) (10 thru 13=4) (14=3) (15=2) (16 thru 19=5) (20=1) (21=SYSMIS) INTO vakuutuspiirit.
VARIABLE LABELS vakuutuspiirit 'Vakuutuspiirit'.
EXECUTE. 

VALUE LABELS
vakuutuspiirit
1 'Eteläinen vakuutuspiiri'
2 'Läntinen vakuutuspiiri'
3 'Keskinen vakuutuspiiri'
4 'Itäinen vakuutuspiiri'
5 'Pohjoinen vakuutuspiiri'.
EXECUTE.

RECODE    k34 (1,2 =1)(3,4=2)(5,6=3) into luokka.

VALUE LABELS    
luokka
1 'ala-luokka'
2 'keski-luokka'
3 'ylä-luokka'.
EXECUTE.

RECODE k62 (MISSING=SYSMIS) (1200 thru 1999=2) (2000 thru 2999=3) (1199 thru Highest=1) (Lowest 
    thru 3000=4) INTO tulokvartaalit.
VARIABLE LABELS  tulokvartaalit 'tulokvartaalit'.
EXECUTE.

VALUE LABELS   
tulokvartaalit
1 'korkeintaan 1200 euroa/kk'
2 '1200 - 2000 euroa/kk'
3 '2000 - 3000 euroa/kk'
4 ' yli 3000 euroa/kk'.
EXECUTE.



COMPUTE ika_uusi=2009-k2.
EXECUTE.

RECODE k25 (1=1) (2 thru 5=2) (ELSE=SYSMIS) INTO aidintyodikot.
VARIABLE LABELS aidintyodikot 'aidintyodikot'.
EXECUTE.

COMPUTE interaktio=k62 * aidintyodikot.
EXECUTE.

COMPUTE interaktio_kvart=tulokvartaalit * aidintyodikot.
EXECUTE.

COMPUTE  tulot_sukup=tulokvartaalit*k1.

* FAKTORIANALYYSI muuttujista k7a - k7k. Extraction: Maximum likelihood, Rotation: Direct oblimin.
* 1: Suhteet, 2: Kotitausta 3: Määrätietoisuus 4: Taustatekijät

FACTOR
  /VARIABLES k7a k7b k7c k7d k7e k7f k7h k7g k7i k7j k7k
  /MISSING PAIRWISE 
  /ANALYSIS k7a k7b k7c k7d k7e k7f k7g k7h k7i k7j k7k
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.20)
  /PLOT ROTATION
  /CRITERIA MINEIGEN(1) FACTORS(4) ITERATE(25) 
  /EXTRACTION ML
  /CRITERIA ITERATE(25) DELTA(0)
  /ROTATION OBLIMIN.

* Summamuuttujien luominen
* Suhteet:

COMPUTE suhteet=mean(k7g,k7f).
RELIABILITY
  /VARIABLES=k7g k7f
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE ANOVA.
 
EXECUTE.

* Kotitausta:

COMPUTE kotitausta=mean(k7b,k7a,k7c).
RELIABILITY
  /VARIABLES=k7b k7a k7c
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE ANOVA.

EXECUTE.

* Määrätietoisuus

COMPUTE maaratiet=mean(k7d ,k7e).
RELIABILITY
  /VARIABLES=k7d k7e
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE ANOVA.

EXECUTE.

* sukupuoli, etnisyys, uskonto

COMPUTE etnisyys=mean(k7i ,k7j, k7k).
RELIABILITY
  /VARIABLES=k7i k7j k7k
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE ANOVA.

EXECUTE.


* KORRELAATIOMATRIISI, jossa tarkastellaan miten faktoroitujen muuttujat korreloivat huono-osaisuuteen. 

CORRELATIONS
  /VARIABLES=k18a_rev suhteet kotitausta maaratiet etnisyys
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

* Bruttotulot huono-osaisuuden selittäjänä
 
FREQUENCIES VARIABLES=tulokvartaalit k18a_rev
  /BARCHART FREQ
  /ORDER=ANALYSIS.

CORRELATIONS
  /VARIABLES=tulokvartaalit k18a_rev
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT k18a_rev
  /METHOD=ENTER tulokvartaalit
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

* REGRESSIOANALYYSIT, jossa selittävänä muuttujana k18a ja selitettävinä kotitausta, suhteet, etnisyys, päämäärätietoisuus

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT suhteet
  /METHOD=ENTER k18a_rev
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT kotitausta
  /METHOD=ENTER k18a_rev
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT maaratiet
  /METHOD=ENTER k18a_rev
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT etnisyys
  /METHOD=ENTER k18a_rev
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

* Interaktio

REGRESSION
/DESCRIPTIVES MEAN STDDEV CORR SIG N
/MISSING LISTWISE
/STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
/CRITERIA=PIN(.05) POUT(.10)
/NOORIGIN
/DEPENDENT k18a
/METHOD=ENTER k62 aidintyodikot
/METHOD=ENTER interaktio
/SCATTERPLOT=(*ZRESID ,*ZPRED)
/RESIDUALS DURBIN HISTOGRAM(ZRESID)
/CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
/DESCRIPTIVES MEAN STDDEV CORR SIG N
/MISSING LISTWISE
/STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
/CRITERIA=PIN(.05) POUT(.10)
/NOORIGIN
/DEPENDENT k18a_rev
/METHOD=ENTER tulokvartaalit k1
/METHOD=ENTER tulot_sukup
/SCATTERPLOT=(*ZRESID ,*ZPRED)
/RESIDUALS DURBIN HISTOGRAM(ZRESID)
/CASEWISE PLOT(ZRESID) OUTLIERS(3).


* VARIANSSIANALYYSI, jossa tarkastellaan koetaanko eri Kelan vakuutuspiireissä eriarvoisuutta eri tavoilla. Posthoc-testinä bonferroni, koska otoskoot erisuuria. 

CROSSTABS
  /TABLES=vakuutuspiirit BY k18a_rev
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ 
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.

UNIANOVA k18a_rev BY vakuutuspiirit
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /POSTHOC=vakuutuspiirit(BONFERRONI GT2) 
  /PRINT ETASQ DESCRIPTIVE HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /DESIGN=vakuutuspiirit.
