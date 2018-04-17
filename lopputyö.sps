
* Encoding: UTF-8.
* Korjattu/muutettu:
    - muuttujat uudelleenkoodattu ja missing valuet määritetty
    - faktorit pakotettu neljään
    
* Selitettäviä muuttujia k18a (ehkä k60) 

* Muuttujien uudelleenkoodaaminen

MISSING VALUES    k7a to k7k (8).

RECODE k7a to k7k (1=5) (2=4) (3=3) (4=2) (5=1).

RECODE    k18a (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4) (8=3) (9=2) (10=1).  

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

RECODE k25 (1=1) (2 thru 5=2) (ELSE=SYSMIS) INTO aidintyodikot.
VARIABLE LABELS aidintyodikot 'aidintyodikot'.
EXECUTE.

COMPUTE interaktio=k62 * aidintyodikot.
EXECUTE.

COMPUTE interaktio_kvart=tulokvartaalit * aidintyodikot.
EXECUTE.

* FAKTORIANALYYSI muuttujista k7a - k7k. Extraction: Maximum likelihood, Rotation: Direct oblimin.
* Näyttäisi jakautuvan aika jees neljälle faktorille. 
* Nimiehdotukset: 1: Suhteet, 2: Kotitausta 3: Määrätietoisuus 4: Taustatekijät

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

* Ikämuuttujan laskeminen

COMPUTE ika_uusi=2009-k2.
EXECUTE.

* Tulokvartaalien laskeminen henkilökohtaisista bruttotuloista

RECODE k62 (MISSING=SYSMIS) (1200 thru 1999=2) (2000 thru 2999=3) (1199 thru Highest=1) (Lowest 
    thru 3000=4) INTO tulokvartaalit.
VARIABLE LABELS  tulokvartaalit 'tulokvartaalit'.
EXECUTE.

* Summamuuttujien luominen. Kattelin läpi nuo descriptivet ja ei tarvii vähentää vastaajia (Mean -1) tjsp.
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

* Mahdollisuuksien tasa-arvo

COMPUTE mahd_tas=mean(k8a, k8b, k8c, k8d).
RELIABILITY
  /VARIABLES=k8a k8b k8c k8d
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE ANOVA.

EXECUTE.

* KORRELAATIOMATRIISI, jossa tarkastellaan miten faktoroitujen muuttujat korreloivat hyväosaisuuteen(huono-osaisuuteen). Suunnat tulee muokata. 

CORRELATIONS
  /VARIABLES=k18a suhteet kotitausta maaratiet etnisyys ika_uusi k1
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

CORRELATIONS
  /VARIABLES=k60 suhteet kotitausta maaratiet etnisyys mahd_tas ika_uusi k1
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

************** Tarkastellaan miten hyvin vastaajan bruttotulot ennustavat luokkaan sijoittumista mukana muuttujat k18a ja k60.  *************
* Toinen muuttujista (k18a tai k60) pitää poistaa. 
* Molemmat korreloi aika hyvin ja mun mielestä tuloilla voidaan perustella tuon huono-osaisuude/hyväosaisuuden empiria, eli oikeutetaan k60 tai k18a käyttö ja se ei sillon jää pelkäksi KOKEMUKSEKSI johonkin kuulumisesta.
 
FREQUENCIES VARIABLES=k62 k60 k18a
  /BARCHART FREQ
  /ORDER=ANALYSIS.

CORRELATIONS
  /VARIABLES=k62 k18a k60 
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT k18a k60
  /METHOD=ENTER k62
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

* Sama kun tulot on uudeelleenkoodattu tulokvartaaleihin

FREQUENCIES VARIABLES=tulokvartaalit k60 k18a
  /BARCHART FREQ
  /ORDER=ANALYSIS.

CORRELATIONS
  /VARIABLES=tulokvartaalit k18a k60 
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=LISTWISE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT k18a k60
  /METHOD=ENTER tulokvartaalit
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

************************************************************************************************************************

* REGRESSIOANALYYSIT, jossa selittävänä muuttujana k18a ja selitettävinä kotitausta, suhteet, etnisyys, päämäärätietoisuus. Taustamuuttujina ikä ja sukupuoli

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT suhteet
  /METHOD=ENTER k18a k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT kotitausta
  /METHOD=ENTER k18a k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT maaratiet
  /METHOD=ENTER k18a k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT etnisyys
  /METHOD=ENTER k18a k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT mahd_tas
  /METHOD=ENTER k18a k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).


* VARIANSSIANALYYSI, jossa tarkastellaan onko eri maakunnissa eroja eriarvoisuuden kokemisessa. Posthoc-testinä bonferroni, koska otoskoot erisuuria. 
* Tuolla on mun käsittääkseni merkitsevä yhteys siten, että Uudellamaan ja Pirkanmaan sekä Uudellamaan ja Keski-Suomen välillä on merkitsevä ero. 

CROSSTABS
  /TABLES=pahkina BY luokka
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.

UNIANOVA luokka BY vakuutuspiirit
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /POSTHOC=vakuutuspiirit(BONFERRONI GT2) 
  /PRINT ETASQ DESCRIPTIVE HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /DESIGN=vakuutuspiirit.

*************** Selittävänä muuttujan luokka (kolmiluokkaisena muuttujana)**************

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT suhteet
  /METHOD=ENTER luokka k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT kotitausta
  /METHOD=ENTER luokka k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT maaratiet
  /METHOD=ENTER luokka k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT etnisyys
  /METHOD=ENTER luokka k1 ika_uusi
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /CASEWISE PLOT(ZRESID) OUTLIERS(3).

************** Interaktio

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

FREQUENCIES tulokvartaalit.

REGRESSION
/DESCRIPTIVES MEAN STDDEV CORR SIG N
/MISSING LISTWISE
/STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
/CRITERIA=PIN(.05) POUT(.10)
/NOORIGIN
/DEPENDENT k18a
/METHOD=ENTER tulokvartaalit aidintyodikot
/METHOD=ENTER interaktio_kvart
/SCATTERPLOT=(*ZRESID ,*ZPRED)
/RESIDUALS DURBIN HISTOGRAM(ZRESID)
/CASEWISE PLOT(ZRESID) OUTLIERS(3).


