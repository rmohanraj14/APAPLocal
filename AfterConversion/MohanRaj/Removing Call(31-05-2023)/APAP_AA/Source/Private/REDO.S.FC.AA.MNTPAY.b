* @ValidationCode : MjotMTExODIyMDYxODpDcDEyNTI6MTY4MDE5MDE1OTczMDpJVFNTOi0xOi0xOi01MjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -52
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.MNTPAY(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose :
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
* AA.ARR - data returned to the routine
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            :
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, FM TO @FM, CONVERT TO CHANGE
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE

*   GOSUB INITIALISE
*   GOSUB OPEN.FILES

*   IF PROCESS.GOAHEAD THEN
*        GOSUB PROCESS
*   END
* PACS00783674 - START
    PROPERTY.CLASS = 'PAYMENT.SCHEDULE'
    AA.ARR = 0
    Y.ARRG.ID = AA.ID
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARRG.ID, PROPERTY.CLASS,'','', RET.IDS, RET.COND, RET.ERR)

    IF RET.COND THEN

        RET.COND = RAISE(RET.COND)

        PAYMENT.TYPE = RET.COND<AA.PS.PAYMENT.TYPE>
        CHANGE @VM TO @FM IN PAYMENT.TYPE        ;** R22 Auto conversion - VM TO @VM, FM TO @FM, CONVERT TO CHANGE

        LOCATE "CONSTANTE" IN PAYMENT.TYPE SETTING POS THEN
            CALC.AMT = RET.COND<AA.PS.CALC.AMOUNT,POS>
            ACTUAL.AMT = RET.COND<AA.PS.ACTUAL.AMT,POS>
        END
        IF CALC.AMT THEN
            AA.ARR = CALC.AMT
        END
        ELSE
            IF ACTUAL.AMT THEN
                AA.ARR = ACTUAL.AMT
            END
        END
    END

RETURN          ;* Program RETURN
* PACS00786674 - END
*-----------------------------------------------------------------------------------
* PROCESS:
* ======
*    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ACT.DET.ERR)
*    Y.ACT.DET.ERR.HST = ''; R.AA.ACCOUNT.DETAILS.HST = ''
*    CALL F.READ(FN.AA.ACCOUNT.DETAILS.HST,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST,Y.ACT.DET.ERR.HST)
*    IF (R.AA.ACCOUNT.DETAILS NE '' OR R.AA.ACCOUNT.DETAILS.HST NE '') THEN
*        Y.CONT = 1 ; NRO.BILLS.H = ''; NRO.BILLS.L = ''
*        NRO.BILLS.H = R.AA.ACCOUNT.DETAILS.HST<AA.AD.BILL.ID>
*        NRO.BILLS.L = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>

*        CONVERT SM TO VM IN NRO.BILLS.H
*        CONVERT SM TO VM IN NRO.BILLS.L

*        NRO.BILLS = NRO.BILLS.H:VM:NRO.BILLS.L
*        Y.CONT = DCOUNT(NRO.BILLS,VM)
*        LOOP
*        WHILE Y.CONT GT 0

*            BILL.REFERENCE = NRO.BILLS<1,Y.CONT>
*            CALL AA.GET.BILL.DETAILS(Y.ARRG.ID, BILL.REFERENCE, BILL.DETAILS, RET.ERROR)

*            LOCATE "INFO" IN BILL.DETAILS<AA.BD.PAYMENT.METHOD, 1> SETTING POS.Y THEN
*                Y.CONT = Y.CONT -1
*            END ELSE
*AA.ARR =  BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>         ;* 35 7
*            END
*        REPEAT
*    END

*    RETURN
*------------------------
* INITIALISE:
* =========
*    PROCESS.GOAHEAD = 1
*    B.CONT = 0
*    Y.ARRG.ID = AA.ID
*    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
*    F.AA.ACCOUNT.DETAILS  = ''
*    R.AA.ACCOUNT.DETAILS = ''
*    AA.ARR = 0
*    BILL.REFERENCE = ''
*    BILL.DETAILS = ''
*    RET.ERROR = ''
*    FN.AA.ACCOUNT.DETAILS.HST = 'F.AA.ACCOUNT.DETAILS.HIST'; F.AA.ACCOUNT.DETAILS.HST = ''
*    RETURN

*------------------------
* OPEN.FILES:
* =========
*    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
*    CALL OPF(FN.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST)
*    RETURN
*------------
END
