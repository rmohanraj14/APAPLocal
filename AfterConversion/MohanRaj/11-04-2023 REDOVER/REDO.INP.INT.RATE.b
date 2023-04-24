* @ValidationCode : MjoyMDI0NTIxODQzOkNwMTI1MjoxNjgxMjExMzk5MjcyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 16:39:59
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
SUBROUTINE REDO.INP.INT.RATE
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : SUDHARSANAN S
* Program Name  : REDO.INP.INT.RATE
* ODR Number    : ODR-2009-10-0317
*-------------------------------------------------------------------------
* Description :This validation routine REDO.AUTH.ACI.UPD which will be executed during
* authorization of version record.When the status changes the system will determine what
* interest conditions should be applied (effective from the time the status changed).The
* interest conditions will be defined in the new template. The information relating to new
* interest rate, status and date of status changed will be record for audit purposed.These
* new fields will only be updated if a condition for the new status exists on the new template
* If no new condition exists then the interest rate will not be changed and the status
* applicable for interest will not be changed When the manually update field is set to yes
* this routine will automatically update the ACCOUNTs (ACI) record

* Linked with: ACCOUNT,TEST
* In parameter : None
* out parameter : None
**----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO         REFERENCE          DESCRIPTION
*08.09.2010  S SUDHARSANAN   HD1036878         INITIAL CREATION
*28-03-2011  S SUDHARSANAN   PACS00033264/65   Check the status1 value based on EB.LOOKUP ID
*16-06-2011  S SUDHARSANAN   PACS00024017      Comment some coding based on issue
*16-08-2011  SHANKAR RAJU    PACS00101170      Adding check to restrict updating ACI while creating account
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,VM TO @VM,F.READ TO CACHE.READ
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CREDIT.INT
    $INSERT I_F.BASIC.INTEREST
    $INSERT I_F.GROUP.CREDIT.INT
    $INSERT I_F.GROUP.DATE
    $INSERT I_F.REDO.ACC.CR.INT
*
    GOSUB INIT
    GOSUB PROCESS
RETURN
*
*-------------------------------------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------------------------------
*
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.ACCOUNT.CREDIT.INT='F.ACCOUNT.CREDIT.INT'
    F.ACCOUNT.CREDIT.INT=''
    CALL OPF(FN.ACCOUNT.CREDIT.INT,F.ACCOUNT.CREDIT.INT)

    FN.REDO.ACC.CR.INT='F.REDO.ACC.CR.INT'
    F.REDO.ACC.CR.INT=''
    CALL OPF(FN.REDO.ACC.CR.INT,F.REDO.ACC.CR.INT)

    FN.BASIC.INTEREST='F.BASIC.INTEREST'
    F.BASIC.INTEREST=''
    CALL OPF(FN.BASIC.INTEREST,F.BASIC.INTEREST)

    FN.GROUP.CREDIT.INT = 'F.GROUP.CREDIT.INT'
    F.GROUP.CREDIT.INT  = ''
    CALL OPF(FN.GROUP.CREDIT.INT,F.GROUP.CREDIT.INT)

    R.GROUP.CREDIT.INT  = ''
    ERR.GCI             = ''

    FN.GROUP.DATE = 'F.GROUP.DATE'
    F.GROUP.DATE  = ''
    CALL OPF(FN.GROUP.DATE,F.GROUP.DATE)

    R.GROUP.DATE  = ''
    GROUP.ERR     = ''

    LREF.APP='ACCOUNT'
    LREF.FIELD='L.AC.STATUS1':@VM:'L.AC.STATUS2':@VM:'L.STAT.INT.RATE':@VM:'L.DATE.INT.UPD':@VM:'L.AC.MAN.UPD'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
    POS.L.AC.STATUS1=LREF.POS<1,1>
    POS.L.AC.STATUS2=LREF.POS<1,2>
    POS.L.STAT.INT.RATE=LREF.POS<1,3>
    POS.L.DATE.INT.UPD=LREF.POS<1,4>
    POS.L.AC.MAN.UPD=LREF.POS<1,5>

RETURN
*
*-------------------------------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------
*

    Y.STATUS2=R.NEW(AC.LOCAL.REF)<1,POS.L.AC.STATUS2>
    Y.MANUAL.UPD=R.NEW(AC.LOCAL.REF)<1,POS.L.AC.MAN.UPD>
    Y.ACCT.NO=ID.NEW
    SM.CNT=DCOUNT(Y.STATUS2,@SM)

*PACS00033264 - S
    IF R.NEW(AC.LOCAL.REF)<1,POS.L.AC.STATUS2,SM.CNT> NE R.OLD(AC.LOCAL.REF)<1,POS.L.AC.STATUS2,SM.CNT> THEN
        Y.NEW.STATUS=R.NEW(AC.LOCAL.REF)<1,POS.L.AC.STATUS2,SM.CNT>
    END ELSE
        IF R.NEW(AC.LOCAL.REF)<1,POS.L.AC.STATUS1> NE R.OLD(AC.LOCAL.REF)<1,POS.L.AC.STATUS1> THEN
            Y.NEW.STATUS=R.NEW(AC.LOCAL.REF)<1,POS.L.AC.STATUS1>
        END
    END
    Y.CATEGORY=R.NEW(AC.CATEGORY)
    Y.UPD.STATUS = Y.NEW.STATUS
    IF Y.UPD.STATUS EQ 'ACTIVE' THEN
        R.NEW(AC.WAIVE.LEDGER.FEE) = ''
    END
*PACS00033264 - E

*PACS00101170 - S
    Y.REC.STAT = R.NEW(AC.RECORD.STATUS)
    Y.CURR.NO  = R.NEW(AC.CURR.NO)

    IF Y.CURR.NO GT 1 THEN
        IF Y.UPD.STATUS NE 'ACTIVE' AND Y.UPD.STATUS NE '' THEN
            Y.REDO.ACI.ID=Y.CATEGORY:'.':Y.UPD.STATUS
            R.REDO.ACC.CR.INT=''
            REDO.ACI.ERR=''
            CALL F.READ(FN.REDO.ACC.CR.INT,Y.REDO.ACI.ID,R.REDO.ACC.CR.INT,F.REDO.ACC.CR.INT,REDO.ACI.ERR)
            IF R.REDO.ACC.CR.INT NE '' THEN
                Y.BASIC.RATE=R.REDO.ACC.CR.INT<ACI.CR.BASIC.RATE,1>
                GOSUB INT.UPD
            END
        END
    END ELSE
        Y.CONDITION.GROUP = R.NEW(AC.CONDITION.GROUP)
        Y.GCI.CUR         = R.NEW(AC.CURRENCY)
        Y.COND.AND.CURR   = Y.CONDITION.GROUP:Y.GCI.CUR

        CALL CACHE.READ(FN.GROUP.DATE, Y.COND.AND.CURR, R.GROUP.DATE, GROUP.ERR) ;*R22 Code conversion
        Y.GCI.ID          =Y.COND.AND.CURR:R.GROUP.DATE<AC.GRD.CREDIT.GROUP.DATE> ;*R22 Code conversion

        CALL CACHE.READ(FN.GROUP.CREDIT.INT, Y.GCI.ID, R.GROUP.CREDIT.INT, ERR.GCI)
        Y.BASIC.RATE = R.GROUP.CREDIT.INT<IC.GCI.CR.BASIC.RATE>

        IF Y.BASIC.RATE EQ '' THEN
            Y.INT.RATE = R.GROUP.CREDIT.INT<IC.GCI.CR.INT.RATE>
            R.NEW(AC.LOCAL.REF)<1,POS.L.STAT.INT.RATE> = Y.INT.RATE
            R.NEW(AC.LOCAL.REF)<1,POS.L.DATE.INT.UPD>  = TODAY
        END ELSE
            GOSUB READ.BASIC.INT
            R.NEW(AC.LOCAL.REF)<1,POS.L.STAT.INT.RATE> = Y.INT.RATE
            R.NEW(AC.LOCAL.REF)<1,POS.L.DATE.INT.UPD>  = TODAY
        END
    END
*PACS00101170 - E

RETURN
*------------------------------------------------------------------------------
INT.UPD:
*-------

    IF Y.BASIC.RATE EQ '' THEN
        Y.INT.RATE=R.REDO.ACC.CR.INT<ACI.CR.INT.RATE,1>
        Y.DATE=TODAY
        R.NEW(AC.LOCAL.REF)<1,POS.L.STAT.INT.RATE>=Y.INT.RATE
        R.NEW(AC.LOCAL.REF)<1,POS.L.DATE.INT.UPD>=Y.DATE
    END ELSE
        GOSUB READ.BASIC.INT

        Y.MARGIN.RATE=R.REDO.ACC.CR.INT<ACI.CR.MARGIN.RATE,1>
        Y.MARGIN.OPER=R.REDO.ACC.CR.INT<ACI.CR.MARGIN.OPER,1>

        BEGIN CASE
            CASE Y.MARGIN.OPER EQ 'ADD'
                Y.INT.RATE=(Y.INT.RATE+Y.MARGIN.RATE)
            CASE Y.MARGIN.OPER EQ 'SUBTRACT'
                Y.INT.RATE=(Y.INT.RATE-Y.MARGIN.RATE)
            CASE Y.MARGIN.OPER EQ 'MULTIPLY'
                Y.INT.RATE=(Y.INT.RATE*Y.MARGIN.RATE)
        END CASE

        Y.DATE=TODAY
        R.NEW(AC.LOCAL.REF)<1,POS.L.STAT.INT.RATE>=Y.INT.RATE
        R.NEW(AC.LOCAL.REF)<1,POS.L.DATE.INT.UPD>=Y.DATE
    END
RETURN
*---------------------------------------------------------------------------
READ.BASIC.INT:
*--------------

    Y.CURR=R.NEW(AC.CURRENCY)
    BASIC.ID=Y.BASIC.RATE:Y.CURR
    SEL.BASIC.LIST=''
    NOR=''
    SEL.ERR=''

    SEL.BASIC="SSELECT ":FN.BASIC.INTEREST:" WITH @ID LIKE ":BASIC.ID:"..."
    CALL EB.READLIST(SEL.BASIC,SEL.BASIC.LIST,'',NOR,SEL.ERR)
    BASIC.REC.ID=SEL.BASIC.LIST<NOR>
    R.BASIC.INTEREST=''
    CALL CACHE.READ(FN.BASIC.INTEREST, BASIC.REC.ID, R.BASIC.INTEREST, BASIC.ERR) ;*R22 Code conversion
    Y.INT.RATE=R.BASIC.INTEREST<EB.BIN.INTEREST.RATE>

RETURN
*---------------------------------------------------------------------------
END
