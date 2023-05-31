* @ValidationCode : MjotMTc5MjUwOTAzNzpDcDEyNTI6MTY4NTUyOTg1NDY0ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:14:14
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
SUBROUTINE REDO.CREATE.ARRANGEMENT.A.AA(RESULT)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.CREATE.ARRANGEMENT.AUTHORISE
* Attached as     : ROUTINE
* Primary Purpose : Build OFS for AA
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            : 11 Julio 2011
* Modify by       : JP - Code review
* Date            : 29 Agosto 2011
* Modify by       : JP - Code review II
* Date            : 18 Octubre 2011
*-----------------------------------------------------------------------------------
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            CALL RTN Format modified
*

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.REDO.FC.FILL.PYSH.LIFE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_System
***********PACS00708597**********************************
    $INSERT I_F.CUSTOMER
*************PACS00708597********************************
    $USING APAP.TAM
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    IF RUNNING.UNDER.BATCH THEN
        RETURN
    END
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS.MAIN
    END

RETURN          ;* Program RETURN




RETURN
*-----------------------------------------------------------------------------------
PROCESS.MAIN:
*=============

    APAP.AA.redoFcSOfsForAaMain(ID.PRODUCT, Y.OFS.MSG.REQ);* MANUAL R22 CODE CONVERSION
    GOSUB WRITE.FILES
    CALL System.setVariable("CURRENT.RCA",Y.ID.RCA)
    CALL F.MATWRITE(FN.RCA.R.NEW, Y.ID.RCA, MAT R.NEW, 500)

*************PACS00708597********************************
    Y.CUSTOMER = R.NEW(REDO.FC.CUSTOMER)
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,Y.CUS.ERR)
    Y.VAL.PROC = R.CUSTOMER<EB.CUS.LOCAL.REF,VAL.POS>
*************PACS00708597********************************

    IF OFS$BROWSER OR OFS$SOURCE.ID EQ 'LN.TEST.OFS' THEN
* Llamada desde la version manual a la version de AA.ARRANGEMENT.ACTIVITY
        IF Y.VAL.PROC EQ 'YES' THEN
            R.NEW(REDO.FC.LN.CREATION.STATUS) = "In Progress"
            R.NEW(REDO.FC.LN.CREATION.ERROR) = ''
            RESULT = 'OK'
            CALL EB.SET.NEW.TASK(NEW.TASKK)
        END ELSE
            RESULT = 'OK'
            CALL EB.SET.NEW.TASK(NEW.TASK)
        END
    END ELSE
        APAP.TAM.redoUtilProcessOfs(Y.OFS.MSG.REQ, Y.OFS.MSG.RES);* R22 Manual conversion
*        GOSUB CHECK.OFS.RESPONSE.TWS
    END

RETURN

*------------------------
**********************
* Check OFS Response
CHECK.OFS.RESPONSE.TWS:
**********************
    Y.APPLICATION.ID = Y.OFS.MSG.REQ[BK.SEPARATOR,1,1]
    MSG.ID = Y.OFS.MSG.RES[BK.SEPARATOR,1,1]
    SUCCESS.FAIL = MSG.ID[SUB.BK.SEPARATOR,3,1]
    MSG.NOT.CHANGED = INDEX(Y.OFS.MSG.RES,'LIVE RECORD NOT CHANGED',1)

* Capture fail message in response
    Y.RESP = Y.OFS.MSG.RES[",",2,99]
    IF Y.RESP EQ '' THEN
        Y.RESP = Y.OFS.MSG.RES
    END

    IF SUCCESS.FAIL NE '1' AND NOT(MSG.NOT.CHANGED) THEN
* ERROR
* OFS Message not validated properly
        RESULT = 'FAIL'
        E = "EB-FC-REVERSE.TRN" : @FM : Y.APPLICATION.ID : @VM : Y.RESP
        RETURN
    END ELSE
* SUCCESS
* Proceed to commit the record
        RESULT = 'OK'
        Y.TXN.COMMITED = 1
    END

RETURN
***********************
WRITE.FILES:
*==============
*Payment Schedule record


    R.REDO.FC.PAYSCH<AA.PS.PAYMENT.TYPE>  = R.NEW(REDO.FC.PAYMENT.TYPE)
    R.REDO.FC.PAYSCH<AA.PS.PAYMENT.METHOD> = R.NEW(REDO.FC.PAYMENT.METHOD)
    R.REDO.FC.PAYSCH<AA.PS.PAYMENT.FREQ> = R.NEW(REDO.FC.PAYMENT.FREQ)
    R.REDO.FC.PAYSCH<AA.PS.PROPERTY> = R.NEW(REDO.FC.PROPERTY)
    R.REDO.FC.PAYSCH<AA.PS.START.DATE> = R.NEW(REDO.FC.START.DATE)
    R.REDO.FC.PAYSCH<AA.PS.END.DATE> = R.NEW(REDO.FC.END.DATE)
    R.REDO.FC.PAYSCH<AA.PS.ACTUAL.AMT> = R.NEW(REDO.FC.ACTUAL.AMT)
    R.REDO.FC.PAYSCH<AA.PS.LOCAL.REF,WPOSL1> = R.NEW(REDO.FC.ACC.TO.DEBIT)
    R.REDO.FC.PAYSCH<AA.PS.LOCAL.REF,WPOSL2> = R.NEW(REDO.FC.FORM)
    R.REDO.FC.PAYSCH<AA.PS.LOCAL.REF,WPOSL3> = R.NEW(REDO.FC.PAYMT.MHD)

    ID.PAYSCH = R.NEW(REDO.FC.ID.ARRANGEMENT)

*Charges Record

    R.REDO.FC.CHARGES<1> = R.NEW(REDO.FC.CHARG.DISC)
    R.REDO.FC.CHARGES<2> = R.NEW(REDO.FC.CHARG.AMOUNT)
    R.REDO.FC.CHARGES<3> = Y.CURRENCY

    ID.CHARGES = R.NEW(REDO.FC.ID.ARRANGEMENT)

*Writes

    WRITE R.REDO.FC.PAYSCH TO F.REDO.FC.PAYSCH, ID.PAYSCH ON ERROR PROCESS.GOAHEAD = 0
    WRITE R.REDO.FC.CHARGES TO F.REDO.FC.CHARGES, ID.CHARGES ON ERROR PROCESS.GOAHEAD = 0

RETURN


INITIALISE:
*=========

    BK.SEPARATOR = ','
    SUB.BK.SEPARATOR = '/'
    ID.PRODUCT = R.NEW(REDO.FC.PRODUCT)
    Y.CURRENCY = R.NEW(REDO.FC.LOAN.CURRENCY)
    Y.OFS.MSG.REQ = ""
    Y.OFS.MSG.RES = ""
    PROCESS.GOAHEAD = 1

    FN.REDO.FC.PAYSCH = 'F.REDO.FC.PAYSCH'
    F.REDO.FC.PAYSCH = ''
    R.REDO.FC.PAYSCH = ''

    FN.REDO.FC.CHARGES = 'F.REDO.FC.CHARGES'
    F.REDO.FC.CHARGES = ''
    R.REDO.FC.CHARGES = ''

    FN.RCA.R.NEW = 'F.RCA.R.NEW'
    F.RCA.R.NEW = ''
*************PACS00708597********************************
    FN.APAP.LN.OFS.CONCAT = 'F.APAP.LN.OFS.CONCAT'
    F.APAP.LN.OFS.CONCAT = ''

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''

    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''

    APPL.NAME.ARR = "CUSTOMER"
    FLD.NAME.ARR = "NEW.LN.PROC"
    FLD.POS.ARR = ""
    CALL MULTI.GET.LOC.REF(APPL.NAME.ARR,FLD.NAME.ARR,FLD.POS.ARR)
    VAL.POS = FLD.POS.ARR<1,1>
*************PACS00708597********************************

    Y.ID.RCA = ID.NEW
    NEW.TASK = 'AA.ARRANGEMENT.ACTIVITY,AA.NEW.FC I F3'
    NEW.TASKK = 'ENQ APAP.E.LN.PROGRESS.ENQ @ID EQ ':Y.ID.RCA
    WAPP.LST = "AA.PRD.DES.PAYMENT.SCHEDULE"
    WCAMPO    = "L.AA.DEBT.AC"
    WCAMPO<2> = "L.AA.FORM"
    WCAMPO<3> = "L.AA.PAY.METHD"
    WCAMPO    = CHANGE(WCAMPO,@FM,@VM)
    CALL MULTI.GET.LOC.REF(WAPP.LST,WCAMPO,YPOS)
    WPOSL1    = YPOS<1,1>
    WPOSL2    = YPOS<1,2>
    WPOSL3    = YPOS<1,3>


RETURN

*------------------------
OPEN.FILES:
*=========
* Abre los archivos para la escritura de datos
    CALL OPF(FN.REDO.FC.PAYSCH, F.REDO.FC.PAYSCH)
    CALL OPF(FN.REDO.FC.CHARGES, F.REDO.FC.CHARGES)
    CALL OPF(FN.APAP.LN.OFS.CONCAT,F.APAP.LN.OFS.CONCAT)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)

RETURN
*------------
END
