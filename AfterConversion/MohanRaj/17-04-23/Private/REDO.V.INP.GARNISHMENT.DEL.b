* @ValidationCode : Mjo2MjAzMjE4NDg6Q3AxMjUyOjE2ODE3MjkwNjY5MTA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:27:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.INP.GARNISHMENT.DEL
*----------------------------------------------------------------------
*Description:
*This is an input routine for the version APAP.H.GARNISH.DETAILS,DEL
*---------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : BHARATH C
* Program Name  : REDO.V.INP.GARNISHMENT.MAINT
* ODR NUMBER    : ODR-2009-10-0531
*----------------------------------------------------------------------
*Input param = none
*output param =none

*-------------------------------------------------------------------------
*Date      Who                ref                    Desc
*01 jun 2011 Prabhu         PACS00071064            line 106 modified
*18 AUG 2011 Prabhu         PACS00103352            APAP.GAR.LOCKED.DEL.TYPE-Lookup Modification added
*18 SEP 2011 Prabhu         PACS00133294            code modified to support multivalue deletion
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,++ TO +=1
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*---------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.APAP.H.GARNISH.DETAILS
    $INSERT I_F.ACCOUNT
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
RETURN

*------------------------------
INIT:
*------------------------------
    LOCK.DEL.TYPE=''
    LOCKED.AMT=''
    GARNISH.DEL.AMT=''
    UNLOCKED.AMT=''

RETURN
*--------------------------------
OPENFILE:
*--------------------------------
    FN.AC.LOCKED.EVENTS='F.AC.LOCKED.EVENTS'
    F.AC.LOCKED.EVENTS=''
    R.AC.LOCKED.EVENTS=''
    ERR.AC.LOCKED.EVENTS=''
    AC.LOCKED.ID=''
    CALL OPF(FN.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT =''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN
*---------------------------------
PROCESS:
*---------------------------------
*Getting the values using R.NEW
*---------------------------------
    LOC.REF.APPLICATION="ACCOUNT"
    LOC.REF.FIELDS='L.AC.AV.BAL'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    Y.BAL.POS=LOC.REF.POS<1,1>
    LOCK.DEL.TYPE=R.NEW(APAP.GAR.LOCKED.DEL.TYPE)<1,1>
    LOCKED.AMT=R.NEW(APAP.GAR.AMOUNT.LOCKED)
    GARNISH.DEL.AMT=R.NEW(APAP.GAR.GARNISH.AMT.DEL)<1,1>
    UNLOCKED.AMT=R.NEW(APAP.GAR.UNLOCKED.AMT)
    SPECIAL.REL=R.NEW(APAP.GAR.SPL.REL.RECORDS)<1,1>
*-----------------------------------
* Checking the cases for the lock deletion type
*-----------------------------------
    BEGIN CASE
*--------------------------
* Checking Garnishment Deletion
*--------------------------
*PACS00103352-S
        CASE LOCK.DEL.TYPE EQ 'GARNISHMENT.DELETION'
            GOSUB GARNISH.DELETE
*----------------------------
* Checking Partial Deletion
*----------------------------
        CASE LOCK.DEL.TYPE EQ 'PARTIAL.DELETION'
            GOSUB PARTIAL.DELETE
*-----------------------------------------
* Checking Extraordinary release Unpledged
*-----------------------------------------
        CASE LOCK.DEL.TYPE EQ 'EXTRAORDINARY.RELEASE'
            IF LOCKED.AMT EQ GARNISH.DEL.AMT THEN
                GOSUB GARNISH.DELETE
            END ELSE
                GOSUB PARTIAL.DELETE
            END
            IF SPECIAL.REL EQ ''  THEN
                AF = APAP.GAR.SPL.REL.RECORDS
                ETEXT = 'EB-INPUT.MISSING'
                CALL STORE.END.ERROR
            END
*------------------------------------------
* Checking Payment To Garnishment Creditor
*------------------------------------------
        CASE LOCK.DEL.TYPE EQ 'PAYMENT.TO.CREDITOR'
            Y.APAP.GAR.BENEFICIARY=R.NEW(APAP.GAR.BENEFICIARY)
            IF LOCKED.AMT EQ GARNISH.DEL.AMT THEN
                GOSUB GARNISH.DELETE
            END ELSE
                GOSUB PARTIAL.DELETE
            END
            IF NOT(Y.APAP.GAR.BENEFICIARY) THEN
                AF=APAP.GAR.BENEFICIARY
                ETEXT = 'EB-INPUT.MISSING'
                CALL STORE.END.ERROR
            END
    END CASE
*PACS00103352-E
RETURN
*------------------------
GARNISH.DELETE:
*------------------------
* block for garnishment deletion
*-------------------------
    IF LOCKED.AMT NE GARNISH.DEL.AMT THEN
        AF=APAP.GAR.GARNISH.AMT.DEL

        ETEXT='EB-GARNISH.AND.LOCK.AMT.NOT.EQ'
        CALL STORE.END.ERROR
    END
    Y.LOCKED.AMOUNT.LIST=R.NEW(APAP.GAR.GARNISH.AMT)
*    Y.BAL.LIST=R.OLD(APAP.GAR.AVAIL.BAL)
    Y.REL.LIST=R.OLD(APAP.GAR.REL.AMT)
    CHANGE @VM TO @FM IN Y.LOCKED.AMOUNT.LIST
*    CHANGE VM TO FM IN Y.BAL.LIST
    Y.TOT.LOCK=DCOUNT(Y.LOCKED.AMOUNT.LIST,@FM)
    Y.LCK.CNT =1
    LOOP
    WHILE Y.LCK.CNT LE Y.TOT.LOCK
*        Y.BAL=''
*        Y.ACCT.NO=R.NEW(APAP.GAR.ACCOUNT.NO)<1,Y.LCK.CNT>
*        CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ERR)
*        Y.BAL=R.ACCOUNT<AC.LOCAL.REF><1,Y.BAL.POS>
*        Y.BAL=Y.BAL+Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
*        Y.BAL.LIST<Y.LCK.CNT>=Y.BAL
        Y.NEXT.REL.AMT=FMT(Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>,"R2#20")
        INS Y.NEXT.REL.AMT BEFORE Y.REL.LIST<1,Y.LCK.CNT,1>
        Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>=0
        Y.LCK.CNT += 1
    REPEAT
    CHANGE @FM TO @VM IN Y.LOCKED.AMOUNT.LIST
*    CHANGE FM TO VM IN Y.BAL.LIST
*    R.NEW(APAP.GAR.AVAIL.BAL)=Y.BAL.LIST
    R.NEW(APAP.GAR.GARNISH.AMT)=Y.LOCKED.AMOUNT.LIST
    R.NEW(APAP.GAR.REL.AMT)    =Y.REL.LIST
RETURN

*--------------------------
PARTIAL.DELETE:
*--------------------------
* Block for partial deletion
*---------------------------
*PACS00071064----------------S
    R.NEW(APAP.GAR.UNLOCKED.AMT)=FMT(UNLOCKED.AMT,"R2#20")
    Y.LOCKED.AMT.DEC     =R.NEW(APAP.GAR.AMOUNT.LOCKED)
    R.NEW(APAP.GAR.AMOUNT.LOCKED)=FMT(Y.LOCKED.AMT.DEC,"R2#20")
    Y.GARNISH.DEL.AMT.DEC=R.NEW(APAP.GAR.GARNISH.AMT.DEL)<1,1>
    R.NEW(APAP.GAR.GARNISH.AMT.DEL)<1,1>=FMT(Y.GARNISH.DEL.AMT.DEC,"R2#20")
*-------------------------------------------------
    IF GARNISH.DEL.AMT GE LOCKED.AMT THEN
        AF = APAP.GAR.GARNISH.AMT.DEL
        AV=1
        ETEXT = 'EB-PARTIAL.DEL.AMT'
        CALL STORE.END.ERROR
    END

    Y.TOT.RELEASE.AMT=0
    Y.RELEASE.AMT=GARNISH.DEL.AMT
    Y.APAP.GAR.FIT.REQ=R.NEW(APAP.GAR.FIT.AMOUNT.REQ)
    IF Y.APAP.GAR.FIT.REQ THEN
        IF Y.RELEASE.AMT GE Y.APAP.GAR.FIT.REQ THEN
            Y.TOT.RELEASE.AMT+=Y.APAP.GAR.FIT.REQ
            Y.APAP.GAR.FIT.REQ=0
        END
        ELSE
            Y.TOT.RELEASE.AMT+=Y.RELEASE.AMT
            Y.APAP.GAR.FIT.REQ -= Y.RELEASE.AMT ;*R22 Auto code conversion
        END
    END
    R.NEW(APAP.GAR.FIT.AMOUNT.REQ)=Y.APAP.GAR.FIT.REQ
    Y.LOCKED.AMOUNT.LIST=R.OLD(APAP.GAR.GARNISH.AMT)
    Y.REL.LIST          =R.OLD(APAP.GAR.REL.AMT)
*    Y.BAL.LIST=R.OLD(APAP.GAR.AVAIL.BAL)
*    CHANGE VM TO FM IN Y.BAL.LIST
    CHANGE @VM TO @FM IN Y.LOCKED.AMOUNT.LIST
    Y.TOT.LOCK=DCOUNT(Y.LOCKED.AMOUNT.LIST,@FM)
    Y.LCK.CNT =1
    LOOP
    WHILE Y.LCK.CNT LE Y.TOT.LOCK
        Y.ACCT.NO=R.NEW(APAP.GAR.ACCOUNT.NO)<1,Y.LCK.CNT>
        CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ERR)
        Y.BAL=R.ACCOUNT<AC.LOCAL.REF><1,Y.BAL.POS>
        Y.NEXT.REL.AMT=0
        IF Y.TOT.RELEASE.AMT LT Y.RELEASE.AMT THEN
            Y.DIFF.AMT       =Y.RELEASE.AMT-Y.TOT.RELEASE.AMT
            Y.TOT.RELEASE.AMT=Y.TOT.RELEASE.AMT+Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
            IF Y.TOT.RELEASE.AMT LE Y.RELEASE.AMT THEN
                Y.BAL=Y.BAL+Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
                Y.NEXT.REL.AMT=Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
                Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>=0
            END
            ELSE
                Y.BAL=Y.BAL+Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
                Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>=Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>-Y.DIFF.AMT
                Y.BAL=Y.BAL-Y.LOCKED.AMOUNT.LIST<Y.LCK.CNT>
                Y.NEXT.REL.AMT=Y.DIFF.AMT
            END
        END
*       Y.BAL.LIST<Y.LCK.CNT>=Y.BAL
        Y.NEXT.REL.AMT=FMT(Y.NEXT.REL.AMT,"R2#20")
        INS Y.NEXT.REL.AMT BEFORE Y.REL.LIST<1,Y.LCK.CNT,1>
*       Y.REL.LIST<1,Y.LCK.CNT,-1>=FMT(Y.NEXT.REL.AMT,"R2#20")
        Y.LCK.CNT += 1
    REPEAT
    CHANGE @FM TO @VM IN Y.LOCKED.AMOUNT.LIST
*    CHANGE FM TO VM IN Y.BAL.LIST
    R.NEW(APAP.GAR.GARNISH.AMT)=Y.LOCKED.AMOUNT.LIST
    R.NEW(APAP.GAR.REL.AMT)    =Y.REL.LIST
*    R.NEW(APAP.GAR.AVAIL.BAL)  =Y.BAL.LIST
RETURN
END
