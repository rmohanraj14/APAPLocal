* @ValidationCode : MjoxNDUxNTY2NDU3OkNwMTI1MjoxNjgxMTEyNDExNjEwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:10:11
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.FC.LIMITE.TOPE.VINC(CUST.ID, CUST.OUT)
*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose : To return evaluation of customer.

*
* Incoming:
* ---------
* CUST.ID - ID FROM CUSTOMER
*
* Outgoing:
* ---------
* CUST.OUT - data returned to the routine
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : mgudino - TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_System
    $INSERT I_RAPID.APP.DEV.COMMON
    $INSERT I_F.REDO.CCRG.CUSTOMER
    $INSERT I_F.REDO.CCRG.RISK.LIMIT.PARAM



    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    Y.ERROR = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL F.READ(FN.CUSTOMER,CUST.ID,R.CUSTOMER,F.CUSTOMER,Y.ERROR)
    IF R.CUSTOMER THEN
        IF R.CUSTOMER<EB.CUS.CUSTOMER.TYPE> EQ 'PROSPECT' THEN
            VI.ARR = ''
            RETURN
        END
    END

    GOSUB PROCESS.RESULT

RETURN


*------------------------
PROCESS.RESULT:
*=============
    R.REDO.CCRG.RISK.LIMIT.PARAM = ''
    YERR = ''
    REDO.CCRG.RISK.LIMIT.PARAM.ID = Y.ID.NAME.LIM
    CALL F.READ(FN.REDO.CCRG.RISK.LIMIT.PARAM,REDO.CCRG.RISK.LIMIT.PARAM.ID,R.REDO.CCRG.RISK.LIMIT.PARAM,F.REDO.CCRG.RISK.LIMIT.PARAM,YERR)
    IF YERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : REDO.CCRG.RISK.LIMIT.PARAM.ID
        CUST.OUT = ETEXT
    END ELSE
        CUST.OUT = R.REDO.CCRG.RISK.LIMIT.PARAM<REDO.CCRG.RLP.MAX.AMOUNT>
    END


RETURN

*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    FN.REDO.CCRG.RISK.LIMIT.PARAM = 'F.REDO.CCRG.RISK.LIMIT.PARAM'
    F.REDO.CCRG.RISK.LIMIT.PARAM = ''
    ID.CUST = ''
    ID.CUST.LIM = ''
    CUST.OUT = ''
    Y.VER.INSURANCE = 'MAN'
    Y.INS.ID = ''
    R.REDO.CCRG.CUSTOMER = ''
    Y.OFS.MSG.RES = ''
    Y.OFS.MSG.REQ = ''

    Y.ID.NAME.LIM = 'GLOBAL.LINKED'

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.REDO.CCRG.RISK.LIMIT.PARAM,F.REDO.CCRG.RISK.LIMIT.PARAM)

RETURN
*------------
END
