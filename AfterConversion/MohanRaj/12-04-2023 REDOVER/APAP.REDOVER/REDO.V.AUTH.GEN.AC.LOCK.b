* @ValidationCode : MjoxNjU0MzUxMzMzOkNwMTI1MjoxNjgxMzAzNzI4MTk2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:18:48
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
SUBROUTINE REDO.V.AUTH.GEN.AC.LOCK
*---------------------------------------------------------------------------------
*This is an Authorisation routine for the version AC.LOCKED.EVENTS,INPUT it will lock
*the customer's account
*----------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : GANESH R
* Program Name  : REDO.V.INP.GARNISHMENT.MAINT
* ODR NUMBER    : ODR-2009-10-0531
* HD REFERENCE  : HD1016159
*Routine Name   :REDO.V.AUTH.LOCK.ACCT
*LINKED WITH:
*----------------------------------------------------------------------
*Input param = none
*output param =none
*-----------------------------------------------------------------------
*MODIFICATION DETAILS:
* Date               By                 HD ISSUE
* 16-02-2011        Prabhu.N            PACS00023885  Routine to post ofs message for AC.LOCKED.EVENTS
* 16-11-2011        Prabhu              PACS00146120
* 11-09-2018        Gopala Krishnan R   PACS00698313 - Post L.AC.LOCKE.TYPE field value as 'Garnishment'
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.LOCKING
    $INSERT I_F.OVERRIDE
    $INSERT I_F.APAP.H.GARNISH.DETAILS
    $INSERT I_F.REDO.GAR.LOCK.ALE
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
RETURN
*----------------------------
INIT:
    Y.LOOP.CNT=1
    LOC.APPLICATION='AC.LOCKED.EVENTS':@FM:'ACCOUNT'
    LOCAL.FIELD='L.AC.CUSTOMER':@VM:'L.AC.GAR.REF.NO':@VM:'L.AC.LOCKE.TYPE':@VM:'L.AC.AVAIL.BAL':@VM:'L.AC.STATUS2':@FM:'L.AC.TRAN.AVAIL'
RETURN
*------------------------------
OPENFILE:

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AC.LOCKED.EVENTS='F.AC.LOCKED.EVENTS'
    F.AC.LOCKED.EVENTS=''
    CALL OPF(FN.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS)

    FN.REDO.GAR.LOCK.ALE='F.REDO.GAR.LOCK.ALE'
    F.REDO.GAR.LOCK.ALE=''
    CALL OPF(FN.REDO.GAR.LOCK.ALE,F.REDO.GAR.LOCK.ALE)
RETURN

*----------------------------
PROCESS:
    CALL MULTI.GET.LOC.REF(LOC.APPLICATION,LOCAL.FIELD,LOC.POS)
    LOC.GAR.REF.POS     = LOC.POS<1,2>
    LOC.AVAIL.BAL.POS   = LOC.POS<1,4>
    LOC.CUSTOMER.POS    = LOC.POS<1,1>
    L.AC.TRAN.AVAIL.POS    = LOC.POS<2,1>
    LOC.L.AC.LOCKE.TYPE.POS  = LOC.POS<1,3>       ;*PACS00698313

    GOSUB PROCESS1
RETURN

********
PROCESS1:
*********
    Y.ACCT.LIST=R.NEW(APAP.GAR.ACCOUNT.NO)
    CHANGE @VM TO @FM IN Y.ACCT.LIST
    Y.ACCT.LIST.CNT=DCOUNT(Y.ACCT.LIST,@FM)
    OFSRECORD=''
    LOOP
    WHILE Y.LOOP.CNT LE Y.ACCT.LIST.CNT
        R.AC.LOCKED.EVENTS<AC.LCK.ACCOUNT.NUMBER> =R.NEW(APAP.GAR.ACCOUNT.NO)<1,Y.LOOP.CNT>
        R.AC.LOCKED.EVENTS<AC.LCK.FROM.DATE> = TODAY
        R.AC.LOCKED.EVENTS<AC.LCK.TO.DATE> = ''
        R.AC.LOCKED.EVENTS<AC.LCK.LOCKED.AMOUNT> = R.NEW(APAP.GAR.GARNISH.AMT)<1,Y.LOOP.CNT>
        R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.GAR.REF.POS> = R.NEW(APAP.GAR.GARNISHMENT.REF)
        R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.AVAIL.BAL.POS> = R.NEW(APAP.GAR.AVAIL.BAL)<1,Y.LOOP.CNT>
        R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.CUSTOMER.POS> = R.NEW(APAP.GAR.CUSTOMER)
        R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.L.AC.LOCKE.TYPE.POS> = "GARNISHMENT"      ;*PACS00698313
        APP.NAME = 'AC.LOCKED.EVENTS'
        OFSFUNCT = 'I'
        PROCESS  = 'PROCESS'
        OFSVERSION = 'AC.LOCKED.EVENTS,LOCK'
        GTSMODE = ''
        NO.OF.AUTH = '0'
        TRANSACTION.ID = ''
        OFS.MSG.ID =''
        OFS.SOURCE.ID = 'REDO.OFS.ACI.UPDATE'
        OFS.ERR = ''
        Y.LOOP.CNT += 1
        CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.AC.LOCKED.EVENTS,OFSRECORD)
        CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
    REPEAT
    Y.ALE.FIT.LIST=R.NEW(APAP.GAR.FIT.ALE)
    IF Y.ALE.FIT.LIST THEN
        Y.CUST=R.NEW(APAP.GAR.CUSTOMER)
        CALL F.READ(FN.REDO.GAR.LOCK.ALE,Y.CUST,R.REDO.GAR.LOCK.ALE,F.REDO.GAR.LOCK.ALE,ERR)
        Y.ALE.EXIST=R.REDO.GAR.LOCK.ALE<TT.ALE.ALE>
        CHANGE @VM TO @FM IN Y.ALE.EXIST
        IF R.REDO.GAR.LOCK.ALE THEN
            CHANGE @VM TO @FM IN Y.ALE.FIT.LIST
            Y.ALE.FIT.TOT.CNT=DCOUNT(Y.ALE.FIT.LIST,@FM)
            Y.ALE.FIT.CNT=1
            LOOP
            WHILE Y.ALE.FIT.CNT LE Y.ALE.FIT.TOT.CNT
                Y.ALE.FIT=Y.ALE.FIT.LIST<Y.ALE.FIT.CNT>
                LOCATE Y.ALE.FIT IN Y.ALE.EXIST SETTING POS ELSE
                    Y.ALE.EXIST<-1>=Y.ALE.FIT
                END
                Y.ALE.FIT.CNT += 1
            REPEAT
            CHANGE @FM TO @VM IN Y.ALE.EXIST
            R.REDO.GAR.LOCK.ALE<TT.ALE.ALE>=Y.ALE.EXIST
        END
        ELSE
            R.REDO.GAR.LOCK.ALE<TT.ALE.ALE,-1>=Y.ALE.FIT.LIST
        END
        R.REDO.GAR.LOCK.ALE<TT.ALE.AHG,-1>=ID.NEW
        CALL F.WRITE(FN.REDO.GAR.LOCK.ALE,Y.CUST,R.REDO.GAR.LOCK.ALE)
        Y.FIT.ACC=R.NEW(APAP.GAR.FIT.ACC)
        CHANGE @VM TO @FM IN Y.FIT.ACC
        Y.FIT.ACC.TOT.CNT=DCOUNT(Y.FIT.ACC,@FM)
        Y.FIT.ACC.CNT=1
        LOOP
        WHILE Y.FIT.ACC.CNT LE Y.FIT.ACC.TOT.CNT
            CALL F.READ(FN.ACCOUNT,Y.FIT.ACC<Y.FIT.ACC.CNT>,R.ACCOUNT,F.ACCOUNT,ERR)
            R.ACCOUNT<AC.LOCAL.REF,L.AC.TRAN.AVAIL.POS>=0
            CALL F.WRITE(FN.ACCOUNT,Y.FIT.ACC<Y.FIT.ACC.CNT>,R.ACCOUNT)
            Y.FIT.ACC.CNT += 1
        REPEAT
    END
RETURN
END
