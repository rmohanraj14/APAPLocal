* @ValidationCode : MjotMjg0OTQ2MzIxOkNwMTI1MjoxNjg1NTI4MDgwMDU5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 15:44:40
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
$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.CHANGE.INT.ARRANGEMENT.RPT(Y.OUT.ARRAY)
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*--------------------------------------------------------------------------------------------------------
*Description  : REDO.AA.CHANGE.INT.ARRANGEMENT.RPT is a no-file enquiry routine for the enquiry REDO.CHANGE.INTEREST.REPORT,
*               the routine is based on the selection criteria selects the records from respective files and displays
*               the processed records
*Linked With  : REDO.APAP.CHANGE.INT.RPT
*In Parameter : N/A
*Out Parameter: ENQ.ARRAY
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date                   Who                  Reference                         Description
*   ------                 ------                -------------                     -------------
* 22-09-2010               JEEVA T               ODR-2010-03-0178                    Initial Creation
* 29-March-2023        Conversion Tool           R22 Auto Code Conversion             FM to @Fm , SM to @SM , VM to @VM
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA, CALL method format changed
*--------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.ID.COMPONENT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.INTEREST.ACCRUALS

    GOSUB OPENFILES
    GOSUB GET.LR.FLD.POS
    GOSUB PROCESS.PARA

RETURN
*--------------------------------------------------------------------------------------------------------
OPENFILES:
*--------------------------------------------------------------------------------------------------------
    FN.AA.ARRANGEMENT='F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT=''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ACTIVITY.HISTORY='F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY=''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.REDO.CHANGE.INT.ARRANGEMENT='F.REDO.CHANGE.INT.ARRANGEMENT'
    F.REDO.CHANGE.INT.ARRANGEMENT=''
    CALL OPF(FN.REDO.CHANGE.INT.ARRANGEMENT,F.REDO.CHANGE.INT.ARRANGEMENT)

    Y.AGENCY.VAL = ''
    Y.PRODUCT.TYPE.VAL = ''
    Y.LOAN.PORTFOLIO.TYPE.VAL = ''
    Y.RATE.CHANGE.DATE.FR.VAL = ''
    Y.RATE.REVIEW.DATE.FR.VAL = ''
    Y.AFFILIATED.COMPANY.VAL = ''
    Y.AFFILIATED.COMPANY.VAL = ''
    Y.CAMPAIGN.TYPE.VAL = ''


RETURN

*-----------------------------------------------------------------------------
LOCATE.VALUE:
*-----------------------------------------------------------------------------

    LOCATE "AGENCY" IN D.FIELDS<1> SETTING Y.AGENCY.POS  THEN
        Y.AGENCY.VAL= D.RANGE.AND.VALUE<Y.AGENCY.POS>
    END

    LOCATE "PRODUCT.TYPE" IN D.FIELDS<1> SETTING Y.PRODUCT.TYPE.POS THEN
        Y.PRODUCT.TYPE.VAL= D.RANGE.AND.VALUE<Y.PRODUCT.TYPE.POS>
    END

    LOCATE "PORTFOLIO.TYPE" IN D.FIELDS<1> SETTING Y.LOAN.PORTFOLIO.TYPE.POS THEN
        Y.LOAN.PORTFOLIO.TYPE.VAL= D.RANGE.AND.VALUE<Y.LOAN.PORTFOLIO.TYPE.POS>
    END

    LOCATE "RATE.CHANGE.DT.FR" IN D.FIELDS<1> SETTING Y.RATE.CHANGE.DATE.FR.POS THEN
        Y.RATE.CHANGE.DATE.FR.VAL= D.RANGE.AND.VALUE<Y.RATE.CHANGE.DATE.FR.POS>
    END

    LOCATE "RATE.REVIEW.DT.FR" IN D.FIELDS<1> SETTING Y.RATE.CHANGE.DATE.FR.POS THEN
        Y.RATE.REVIEW.DATE.FR.VAL= D.RANGE.AND.VALUE<Y.RATE.CHANGE.DATE.FR.POS>
    END

    LOCATE "AFFILIATED.COMPANY" IN D.FIELDS<1> SETTING Y.AFFILIATED.COMPANY.POS THEN
        Y.AFFILIATED.COMPANY.VAL= D.RANGE.AND.VALUE<Y.AFFILIATED.COMPANY.POS>
    END

    LOCATE "CAMPAIGN.TYPE" IN D.FIELDS<1> SETTING Y.CAMPAIGN.TYPE.POS THEN
        Y.CAMPAIGN.TYPE.VAL= D.RANGE.AND.VALUE<Y.CAMPAIGN.TYPE.POS>
    END

RETURN
*-----------------------------------------------------------------------------
SELECT.CMD:
*-----------------------------------------------------------------------------

    SEL.CMD.AA = "SELECT ":FN.REDO.CHANGE.INT.ARRANGEMENT
RETURN

*-----------------------------------------------------------------------------
PROCESS.PARA:
*-----------------------------------------------------------------------------

    GOSUB LOCATE.VALUE
    GOSUB SELECT.CMD

    CALL EB.READLIST(SEL.CMD.AA,SEL.LIST.AA,'',NO.OF.AA.REC,SEL.ERR.AA)

    LOOP
        REMOVE Y.CONCAT.ID FROM SEL.LIST.AA SETTING AA.POS
    WHILE Y.CONCAT.ID : AA.POS
        Y.AA.ID = FIELD(Y.CONCAT.ID,"-",1)

        CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.AA.ARR.ERR)
        Y.ERROR.FLAG = ''
        Y.EFFECTIVE.DATE = ''
        GOSUB ARR.SELECT
        IF Y.ERROR.FLAG ELSE
            IF Y.CAMPAIGN.TYPE.VAL OR Y.AFFILIATED.COMPANY.VAL THEN
                GOSUB GET.CUSTOMER.SELECTION
            END
        END

        IF Y.RATE.REVIEW.DATE.FR.VAL AND Y.ERROR.FLAG EQ '' THEN
            GOSUB GET.REVIEW.SELECTION
        END

        IF Y.RATE.CHANGE.DATE.FR.VAL AND Y.ERROR.FLAG EQ '' THEN
            GOSUB GET.CHANGE.SELECTION
        END
        IF  Y.ERROR.FLAG ELSE
            Y.PROCESSED.IDS<-1> := Y.AA.ID
        END

    REPEAT

    IF NOT(Y.PROCESSED.IDS) THEN
        RETURN
    END
    GOSUB GET.DETAILS

RETURN

*-----------------------------------------------------------------------------
ARR.SELECT:
*-----------------------------------------------------------------------------

    IF Y.PRODUCT.TYPE.VAL EQ '' AND Y.LOAN.PORTFOLIO.TYPE.VAL EQ '' AND Y.AGENCY.VAL EQ '' THEN
        RETURN
    END
    IF Y.PRODUCT.TYPE.VAL NE '' THEN
        Y.PRODUCT.TYPE=R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
        IF Y.PRODUCT.TYPE.VAL NE Y.PRODUCT.TYPE THEN
            Y.ERROR.FLAG = '1'
        END
    END

    IF Y.LOAN.PORTFOLIO.TYPE.VAL NE '' THEN
        Y.LOAN.PORTFOLIO = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
        IF Y.LOAN.PORTFOLIO.TYPE.VAL NE Y.LOAN.PORTFOLIO THEN
            Y.ERROR.FLAG = '1'
        END
    END

    IF Y.AGENCY.VAL NE '' THEN
        Y.AGENCY=R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
        IF Y.AGENCY.VAL NE Y.AGENCY THEN
            Y.ERROR.FLAG = '1'
        END
    END
RETURN

*--------------------------------------------------------------------------------------------------------
GET.CONDITION:
*--------------------------------------------------------------------------------------------------------
    ARR.ID=Y.AA.ID
    EFF.DATE=TODAY
    PROPERTY=''
    R.CONDITION =''
    ERR.MSG=''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
RETURN
*--------------------------------------------------------------------------------------------------------
GET.CUSTOMER.SELECTION:
*--------------------------------------------------------------------------------------------------------
    PROP.CLASS='CUSTOMER'
    GOSUB GET.CONDITION

    IF Y.CAMPAIGN.TYPE.VAL AND NOT(Y.AFFILIATED.COMPANY.VAL) THEN
        GOSUB CHECK.CAMP.TYPE
    END

    IF NOT(Y.CAMPAIGN.TYPE.VAL) AND Y.AFFILIATED.COMPANY.VAL THEN
        GOSUB CHECK.AFF.COMP
    END

    IF Y.CAMPAIGN.TYPE.VAL AND Y.AFFILIATED.COMPANY.VAL THEN
        GOSUB CHECK.CAMP.TYPE.AFF.COMP
    END

RETURN

*--------------------------------------------------------------------------------------------------------
CHECK.CAMP.TYPE:
*--------------------------------------------------------------------------------------------------------
    Y.CAMP.VAL = R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.CAMP.TY.POS>

    IF Y.CAMPAIGN.TYPE.VAL EQ Y.CAMP.VAL ELSE
        Y.ERROR.FLAG = '1'
    END

RETURN
*--------------------------------------------------------------------------------------------------------
CHECK.AFF.COMP:
*--------------------------------------------------------------------------------------------------------
    Y.AFF.VAL= R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.AFF.COM.POS>

    IF Y.AFFILIATED.COMPANY.VAL EQ Y.AFF.VAL ELSE
        Y.ERROR.FLAG = '1'
    END

RETURN
*--------------------------------------------------------------------------------------------------------
CHECK.CAMP.TYPE.AFF.COMP:
*--------------------------------------------------------------------------------------------------------
    Y.AFF.VAL1 = R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.AFF.COM.POS>
    Y.CAMP.VAL1 = R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.CAMP.TY.POS>

    IF Y.CAMPAIGN.TYPE.VAL EQ Y.CAMP.VAL1 AND Y.AFFILIATED.COMPANY.VAL EQ Y.AFF.VAL1 ELSE
        Y.ERROR.FLAG = '1'
    END

RETURN

*-----------------------------------------------------------------------------
GET.REVIEW.SELECTION:
*-----------------------------------------------------------------------------

    PROP.CLASS='INTEREST'
    GOSUB GET.CONDITION

    Y.RATE.REVIEW.DT.TO.VAL=FIELD(Y.RATE.REVIEW.DATE.FR.VAL,@SM,2) ;*R22 Auto Code Conversion
    Y.RATE.REVIEW.DT.FROM.VAL=FIELD(Y.RATE.REVIEW.DATE.FR.VAL,@SM,1) ;*R22 Auto Code Conversion
    Y.RATE.REVIEW.DT.TO.VAL.CNT = LEN(Y.RATE.REVIEW.DT.TO.VAL)
    Y.RATE.REVIEW.DT.FROM.VAL.CNT = LEN(Y.RATE.REVIEW.DT.FROM.VAL)

    IF Y.RATE.REVIEW.DT.TO.VAL AND NOT(Y.RATE.REVIEW.DT.FROM.VAL) THEN
        GOSUB CHECK.TO.REVIEW
    END

    IF NOT(Y.RATE.REVIEW.DT.TO.VAL) AND Y.RATE.REVIEW.DT.FROM.VAL THEN
        GOSUB CHECK.FROM.REVIEW
    END

    IF Y.RATE.REVIEW.DT.TO.VAL AND Y.RATE.REVIEW.DT.FROM.VAL THEN
        GOSUB CHECK.TO.FROM.REVIEW
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.TO.REVIEW:
*-----------------------------------------------------------------------------

    Y.NEXT.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.NXT.REV.DT.POS>
    Y.FIRST.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.FIRST.REV.DT.POS>
    Y.LAST.REVIEW.DATE  = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.LAST.REV.DT.POSS>


    IF Y.RATE.REVIEW.DT.TO.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.NEXT.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.NEXT.REVIEW.DATE ELSE
        IF Y.FIRST.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.FIRST.REVIEW.DATE ELSE
            IF Y.LAST.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.LAST.REVIEW.DATE ELSE
                Y.ERROR.FLAG = '1'
                RETURN
            END
        END
    END


RETURN
*-----------------------------------------------------------------------------
CHECK.FROM.REVIEW:
*-----------------------------------------------------------------------------
    Y.NEXT.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.NXT.REV.DT.POS>
    Y.FIRST.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.FIRST.REV.DT.POS>
    Y.LAST.REVIEW.DATE  = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.LAST.REV.DT.POSS>


    IF Y.RATE.REVIEW.DT.FROM.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.NEXT.REVIEW.DATE AND Y.NEXT.REVIEW.DATE ELSE
        IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.FIRST.REVIEW.DATE AND Y.FIRST.REVIEW.DATE ELSE
            IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.LAST.REVIEW.DATE AND Y.LAST.REVIEW.DATE ELSE
                Y.ERROR.FLAG = '1'
                RETURN
            END
        END
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.TO.FROM.REVIEW:
*-----------------------------------------------------------------------------
    Y.NEXT.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.NXT.REV.DT.POS>
    Y.FIRST.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.FIRST.REV.DT.POS>
    Y.LAST.REVIEW.DATE  = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.LAST.REV.DT.POSS>


    IF Y.RATE.REVIEW.DT.FROM.VAL.CNT NE '8' AND Y.RATE.REVIEW.DT.TO.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.REVIEW.DT.TO.VAL LT Y.RATE.REVIEW.DT.FROM.VAL THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.NEXT.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.NEXT.REVIEW.DATE ELSE
        IF Y.FIRST.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.FIRST.REVIEW.DATE ELSE
            IF Y.LAST.REVIEW.DATE LT Y.RATE.REVIEW.DT.TO.VAL AND Y.LAST.REVIEW.DATE ELSE
                Y.ERROR.FLAG = '1'
                RETURN
            END
        END
    END
    IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.NEXT.REVIEW.DATE AND Y.NEXT.REVIEW.DATE ELSE
        IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.FIRST.REVIEW.DATE AND Y.FIRST.REVIEW.DATE ELSE
            IF Y.RATE.REVIEW.DT.FROM.VAL LT Y.LAST.REVIEW.DATE AND Y.LAST.REVIEW.DATE ELSE
                Y.ERROR.FLAG = '1'
                RETURN
            END
        END
    END
RETURN
*-----------------------------------------------------------------------------
GET.CHANGE.SELECTION:
*-----------------------------------------------------------------------------

    GOSUB GET.AA.INTEREST.ACCRUALS.DETAILS

    Y.RATE.CHANGE.DT.TO.VAL=FIELD(Y.RATE.CHANGE.DATE.FR.VAL,@SM,2) ;*R22 Auto Code Conversion
    Y.RATE.CHANGE.DT.FROM.VAL=FIELD(Y.RATE.CHANGE.DATE.FR.VAL,@SM,1) ;*R22 Auto Code Conversion
    Y.RATE.CHANGE.DT.TO.VAL.CNT = LEN(Y.RATE.CHANGE.DT.TO.VAL)
    Y.RATE.CHANGE.DT.FROM.VAL.CNT = LEN(Y.RATE.CHANGE.DT.FROM.VAL)

    IF Y.RATE.CHANGE.DT.TO.VAL AND NOT(Y.RATE.CHANGE.DT.FROM.VAL) THEN
        GOSUB CHECK.TO.CHANGE
    END

    IF NOT(Y.RATE.CHANGE.DT.TO.VAL) AND Y.RATE.CHANGE.DT.FROM.VAL THEN
        GOSUB CHECK.FROM.CHANGE
    END
    IF Y.RATE.CHANGE.DT.TO.VAL AND Y.RATE.CHANGE.DT.FROM.VAL THEN
        GOSUB CHECK.TO.FROM.CHANGE
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.TO.CHANGE:
*-----------------------------------------------------------------------------

    IF NOT(Y.EFFECTIVE.DATE) THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.TO.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.TO.VAL LT Y.EFFECTIVE.DATE THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.FROM.CHANGE:
*-----------------------------------------------------------------------------

    IF NOT(Y.EFFECTIVE.DATE) THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.FROM.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.FROM.VAL GT Y.EFFECTIVE.DATE THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.TO.FROM.CHANGE:
*-----------------------------------------------------------------------------

    IF NOT(Y.EFFECTIVE.DATE) THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.FROM.VAL.CNT NE '8' AND Y.RATE.CHANGE.DT.TO.VAL.CNT NE '8' THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.TO.VAL LT Y.RATE.CHANGE.DT.FROM.VAL THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF Y.RATE.CHANGE.DT.TO.VAL LT Y.EFFECTIVE.DATE THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END
    IF  Y.RATE.CHANGE.DT.FROM.VAL GT Y.EFFECTIVE.DATE THEN
        Y.ERROR.FLAG = '1'
        RETURN
    END

RETURN
*-----------------------------------------------------------------------------
GET.LR.FLD.POS:
*-----------------------------------------------------------------------------
    Y.LRF.APPL = "AA.PRD.DES.INTEREST":@FM:'AA.ARR.CUSTOMER' ;*R22 Auto Code Conversion
    Y.LRF.FIELDS = "L.AA.NXT.REV.DT":@VM:"L.AA.FIR.REV.DT":@VM:"L.AA.LST.REV.DT":@FM:'L.AA.CAMP.TY':@VM:'L.AA.AFF.COM' ;*R22 Auto Code Conversion
    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(Y.LRF.APPL,Y.LRF.FIELDS,FIELD.POS)
    LOC.L.AA.CAMP.TY.POS = FIELD.POS<2,1>
    LOC.L.AA.AFF.COM.POS = FIELD.POS<2,2>
    L.AA.NXT.REV.DT.POS = FIELD.POS<1,1>
    L.AA.FIRST.REV.DT.POS  = FIELD.POS<1,2>
    L.AA.LAST.REV.DT.POSS  = FIELD.POS<1,3>

RETURN

*----------------------------------------------------------------------------------------------------------
GET.AA.INTEREST.ACCRUALS.DETAILS:
*----------------------------------------------------------------------------------------------------------
    Y.EFF.DATE = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE>
    ARR.INFO<1> =Y.AA.ID
    R.ARRANGEMENT=''
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    INT.PROPERTY = ''
    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes
    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    CLASS.CTR = ''
    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ "INTEREST" THEN
            INT.PROPERTY<-1> = PROP.LIST<CLASS.CTR>
        END
        IF Y.CLASS EQ "PAYMENT.SCHEDULE" THEN
            PS.PROPERTY=PROP.LIST<CLASS.CTR>
        END
    REPEAT
    CHANGE @FM TO '*' IN INT.PROPERTY ;*R22 Auto Code Conversion
    Y.COUNT.PROP = DCOUNT(INT.PROPERTY,'*')
    INIT = 1
    LOOP
    WHILE INIT LE Y.COUNT.PROP
        Y.FIRST.PROP = FIELD(INT.PROPERTY,'*',INIT)
        GOSUB AA.ARRG.ACTIVITY
        INIT += 1 ;*R22 Auto Code Conversion
    REPEAT

RETURN

*-----------------------------------------------------------------------------
AA.ARRG.ACTIVITY:
*-----------------------------------------------------------------------------

    CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.AA.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,Y.ERR.ACT.HIS)       ;*Process Arrangement activity records with LENDING-CHANGE-PRINCIPALINT
    IF R.AA.ACTIVITY.HISTORY THEN
        Y.EFFECTIVE.DATE.HIS=R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE>  ;* getting the all effective date
        Y.EFFECTIVE.DATE.COUNT=DCOUNT(Y.EFFECTIVE.DATE.HIS,@VM) ;*R22 Auto Code Conversion
        Y.COUNT=1

        LOOP
        WHILE Y.COUNT LE Y.EFFECTIVE.DATE.COUNT
            Y.ACTIVITY.HIS = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY,Y.COUNT>  ;* getting the activity for the first effective date
            Y.ACT.COUNT=DCOUNT(Y.ACTIVITY.HIS,@SM) ;*R22 Auto Code Conversion
            Y.COUNT1 = 1

            LOOP
            WHILE Y.COUNT1 LE Y.ACT.COUNT
                Y.ACTIVITY = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY,Y.COUNT,Y.COUNT1>
                Y.EFF.DATE =   R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE,Y.COUNT>
                Y.ACT.CHECK='LENDING-CHANGE':'-':Y.FIRST.PROP
                IF Y.ACTIVITY EQ Y.ACT.CHECK  THEN
                    Y.EFFECTIVE.DATE=R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE,Y.COUNT>
                END
                Y.COUNT1 += 1 ;*R22 Auto Code Conversion
            REPEAT

            Y.COUNT += 1 ;*R22 Auto Code Conversion
        REPEAT

    END

RETURN
*--------------------------------------------------------------------------------------------------------
GET.DETAILS:
*--------------------------------------------------------------------------------------------------------

*CALL REDO.AA.CHANGE.INT.ARRANGEMENT.RPT.GET(Y.PROCESSED.IDS,Y.OUT.ARRAY)
    APAP.AA.redoAaChangeIntArrangementRptGet(Y.PROCESSED.IDS,Y.OUT.ARRAY) ;*R22 Manual Code conversion
   
RETURN
*--------------------------------------------------------------------------------------------------------
END
