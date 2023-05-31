* @ValidationCode : MjotMTAyMjM4NjE3MTpDcDEyNTI6MTY4NTUyOTE5NTcyMDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:03:15
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
$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.OVERPAYMENT.PROG(Y.ID)
*------------------------------------------------------------------
*Description: This post cob routine will change the new payment end date when
*             overpayment is made on programmed loan. So that bill will not have
*             zero principal.
*------------------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       No changes
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   CALL routine format modified
*---------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_REDO.B.AA.OVERPAYMENT.PROG.COMMON
    $USING APAP.TAM

    GOSUB PROCESS

RETURN
*------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------
    Y.AA.ID      = FIELD(Y.ID,"*",1)
    Y.OVERPAY.ID = FIELD(Y.ID,"*",2)
    CALL OCOMO("Process started - ":Y.ID)



    GOSUB GET.ACCOUNT.PROPERTY
    GOSUB GET.NEW.SCHEDULE.DATE
    IF Y.LAST.CAPITAL.DATE THEN
        GOSUB POST.OFS
    END ELSE
        CALL OCOMO("No OFS message has been posted")
    END
    CALL F.DELETE(FN.REDO.B.AA.OVERPAYMENT.PROG.LIST,Y.ID)

RETURN
*------------------------------------------------------------------
GET.ACCOUNT.PROPERTY:
*------------------------------------------------------------------

    Y.ACCOUNT.PROPERTY = ""
    APAP.TAM.redoGetPropertyName(Y.AA.ID,"ACCOUNT",R.OUT.AA.RECORD,Y.ACCOUNT.PROPERTY,OUT.ERR) ;*Manual R22 conversion
    Y.PAYSCH.PROPERTY  = ""
    APAP.TAM.redoGetPropertyName(Y.AA.ID,"PAYMENT.SCHEDULE",R.OUT.AA.RECORD,Y.PAYSCH.PROPERTY,OUT.ERR) ;*Manual R22 conversion
    IF Y.ACCOUNT.PROPERTY OR Y.PAYSCH.PROPERTY ELSE
        CALL OCOMO("Account or Paysch property missing - ":Y.ID)
        GOSUB END1
    END

RETURN
*------------------------------------------------------------------
GET.NEW.SCHEDULE.DATE:
*------------------------------------------------------------------

    NO.RESET       = ''
    DATE.RANGE     = ''
    SIMULATION.REF = ''
    CALL AA.SCHEDULE.PROJECTOR(Y.AA.ID, SIMULATION.REF, NO.RESET, DATE.RANGE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)

    Y.LAST.CAPITAL.DATE = ""
    Y.VAR1 =1
    Y.DUE.DATES.CNT = DCOUNT(DUE.DATES,@FM)
    LOOP
    WHILE Y.VAR1 LE Y.DUE.DATES.CNT
        LOCATE Y.ACCOUNT.PROPERTY IN DUE.PROPS<Y.VAR1,1> SETTING ACC.POS THEN
            IF DUE.PROP.AMTS<Y.VAR1,ACC.POS> EQ 0 AND Y.LAST.CAPITAL.DATE EQ "" THEN
                Y.LAST.CAPITAL.DATE = DUE.DATES<Y.VAR1-1>
            END ELSE
                IF DUE.PROP.AMTS<Y.VAR1,ACC.POS> NE 0 THEN
                    Y.LAST.CAPITAL.DATE = ""      ;* Here we are nullfying the variable when they are some future bills having principal component after some zero principal bills (To handle ZPI).
                END
            END
        END
        Y.VAR1 += 1
    REPEAT
RETURN
*------------------------------------------------------------------
POST.OFS:
*------------------------------------------------------------------


    EFF.DATE   = ''
    PROP.CLASS = 'PAYMENT.SCHEDULE'
    PROPERTY   = ''
    R.CONDITION.PAYSCH = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.PAYSCH,ERR.MSG) ;*Manual R22 conversion
    R.AAA = ""

    Y.VAR2 = 1
    Y.PAYMENT.TYPES = R.CONDITION.PAYSCH<AA.PS.PAYMENT.TYPE>
    Y.PAYMENT.TYPES.CNT = DCOUNT(Y.PAYMENT.TYPES,@VM)
    LOOP
    WHILE Y.VAR2 LE Y.PAYMENT.TYPES.CNT

        Y.END.DATE     = R.CONDITION.PAYSCH<AA.PS.END.DATE,Y.VAR2>
        Y.END.DATE.CNT = DCOUNT(Y.END.DATE,@SM)
        Y.VAR3 = 1
        LOOP
        WHILE Y.VAR3 LE Y.END.DATE.CNT
            IF R.CONDITION.PAYSCH<AA.PS.END.DATE,Y.VAR2,Y.VAR3> GT Y.LAST.CAPITAL.DATE THEN
                R.AAA<AA.ARR.ACT.FIELD.NAME,1,-1>  = "END.DATE:":Y.VAR2:":":Y.VAR3
                R.AAA<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.LAST.CAPITAL.DATE
            END

            Y.VAR3 += 1
        REPEAT


        Y.VAR2 += 1
    REPEAT
    IF R.AAA NE "" THEN
        R.AAA<AA.ARR.ACT.PROPERTY>       = Y.PAYSCH.PROPERTY
        R.AAA<AA.ARR.ACT.ARRANGEMENT>    = Y.AA.ID
        R.AAA<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
        R.AAA<AA.ARR.ACT.ACTIVITY>       = "REDO.REDUCE.PAYSCH.OVERPAY"

    END ELSE
        CALL OCOMO("R.AAA is null - ":Y.ID)
        GOSUB END1
    END

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    OFSFUNCT = 'I'
    PROCESS  = ''
    OFSVERSION ='AA.ARRANGEMENT.ACTIVITY,APAP'
    GTSMODE    = ''
    TRANSACTION.ID=''
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    NO.OF.AUTH=''
    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.AAA,OFSRECORD)
    OFS.SRC='REDO.OVERPAY'
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.ID,OFS.SRC,OPTIONS)

    CALL OCOMO("Ofs message has been posted - ": OFS.ID : "And Process completed -":Y.ID)


RETURN
*------------------------------------------------------------------
END1:
    CALL F.DELETE(FN.REDO.B.AA.OVERPAYMENT.PROG.LIST,Y.ID)
END
