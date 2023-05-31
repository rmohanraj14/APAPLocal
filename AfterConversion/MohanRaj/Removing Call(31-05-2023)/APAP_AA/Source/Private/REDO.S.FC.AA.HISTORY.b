* @ValidationCode : MjotNTYzNjYwNDY5OkNwMTI1MjoxNjgwMTkwMTU4OTc0OklUU1M6LTE6LTE6NDM4OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 438
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE APAP.AA
SUBROUTINE REDO.S.FC.AA.HISTORY(AA.ID, AA.ARR)

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
* ---------te
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
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, I TO I.VAR, ++ TO += 1
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN

*-----------------------------------------------------------------------------------
PROCESS:
*=======
    II = 0

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ACT.DET.ERR)
    Y.ACT.DET.ERR.HST = ''; R.AA.ACCOUNT.DETAILS.HST = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS.HST,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST,Y.ACT.DET.ERR.HST)

    IF (R.AA.ACCOUNT.DETAILS NE '' OR R.AA.ACCOUNT.DETAILS.HST NE '') THEN

        Y.CONT = 1 ; NRO.BILLS.H = ''; NRO.BILLS.L = ''
        NRO.BILLS.H = R.AA.ACCOUNT.DETAILS.HST<AA.AD.BILL.ID>
        NRO.BILLS.L = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>

        NRO.BILLS = NRO.BILLS.H:@VM:NRO.BILLS.L
        Y.CONT = DCOUNT(NRO.BILLS,@VM)

        FOR I.VAR=Y.CONT TO 1 STEP -1      ;** R22 Auto conversion - I TO I.VAR

            BILL.REFERENCE = NRO.BILLS<1,I.VAR>     ;** R22 Auto conversion - I TO I.VAR
            CALL AA.GET.BILL.DETAILS(Y.ARRG.ID, BILL.REFERENCE, BILL.DETAILS, RET.ERROR)
            IF BILL.DETAILS THEN
*------------------------------------------------------------------
                GOSUB CHECK.PAY.DATE
*------------------------------------------------------------------
                GOSUB CHECK.REPAY.REF
*------------------------------------------------------------------
                GOSUB CHECK.OR.AMOUNT
*------------------------------------------------------------------
                GOSUB CHECK.OS.AMOUNT
                II += 1      ;** R22 Auto conversion - ++ TO += 1
                IF II EQ 12 THEN
                    BREAK
                END
            END
        NEXT
    END


RETURN
*----------------------------------------------------------------------------
CHECK.PAY.DATE:
*-----------------------------------------------------------------------------
    Y.CUR.CAMPO = "PAYMENT.DATE"
    Y.VALUE.FLD =  BILL.DETAILS<AA.BD.PAYMENT.DATE>         ;*2
    Y.VALUE.FLD = Y.CUR.CAMPO:"*":Y.VALUE.FLD
    AA.ARR <-1> = Y.VALUE.FLD
RETURN
*----------------------------------------------------------------------------
CHECK.REPAY.REF:
*----------------------------------------------------------------------------
    Y.CUR.CAMPO = "REPAY.REF"
    Y.VALUE.FLD =  BILL.DETAILS<AA.BD.REPAY.REF,1>          ;*15
    IF NOT(Y.VALUE.FLD) THEN
        Y.VALUE.FLD = "NULO"
    END
    Y.VALUE.FLD = Y.CUR.CAMPO:"*":Y.VALUE.FLD
    AA.ARR <-1> = Y.VALUE.FLD
RETURN
*-----------------------------------------------------------------------------
CHECK.OR.AMOUNT:
*-----------------------------------------------------------------------------
    Y.CUR.CAMPO = "OR.TOTAL.AMOUNT"
    Y.VALUE.FLD =  BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>      ;*6
    IF NOT(Y.VALUE.FLD) THEN
        Y.VALUE.FLD = 0
    END
    Y.VALUE.FLD = Y.CUR.CAMPO:"*":Y.VALUE.FLD
    AA.ARR <-1> = Y.VALUE.FLD

RETURN
*---------------------------------------------------------------------------
CHECK.OS.AMOUNT:
*----------------------------------------------------------------------------
    Y.CUR.CAMPO = "OS.TOTAL.AMOUNT"
    Y.VALUE.FLD =  SUM(BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)  ;*8
    IF NOT(Y.VALUE.FLD) THEN
        Y.VALUE.FLD = 0
    END
    IF Y.VALUE.FLD LE 0 THEN
        Y.VALUE.FLD =  BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>
    END ELSE
        Y.VALUE.FLD2 =  BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>
        Y.VALUE.FLD = Y.VALUE.FLD2 - Y.VALUE.FLD
    END
    Y.VALUE.FLD = Y.CUR.CAMPO:"*":Y.VALUE.FLD
    AA.ARR <-1> = Y.VALUE.FLD
RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    Y.ARRG.ID = AA.ID

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS  = ''
    R.AA.ACCOUNT.DETAILS = ''

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS  = ''
    R.AA.BILL.DETAILS  = ''
    FN.AA.ACCOUNT.DETAILS.HST = 'F.AA.ACCOUNT.DETAILS.HIST'; F.AA.ACCOUNT.DETAILS.HST = ''
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF (FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
    CALL OPF(FN.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST)
RETURN
*------------
END
