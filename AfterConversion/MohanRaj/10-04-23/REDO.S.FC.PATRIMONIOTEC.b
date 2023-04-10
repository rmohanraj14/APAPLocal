* @ValidationCode : MjotMTM4OTM1NjAzNzpDcDEyNTI6MTY4MTExMjUxNTIxNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:11:55
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
SUBROUTINE REDO.S.FC.PATRIMONIOTEC(CUST.ID, CUST.OUT)
*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose : To return value of PATRIMONIO TECNICO IN REDO.CCRG.TECHNICAL.RESERVES TABLE.
*
* Incoming:
* ---------
* CUST.ID - ID FROM CUSTOMER
*
* Outgoing:
* ---------
* CUST.OUT - value to display in ENQUIRY
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
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CCRG.TECHNICAL.RESERVES

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    R.REDO.CCRG.TECHNICAL.RESERVES = ''
    YERR = ''
    REDO.CCRG.TECHNICAL.RESERVES.ID = 'SYSTEM'
    CALL CACHE.READ (FN.REDO.CCRG.TECHNICAL.RESERVES, REDO.CCRG.TECHNICAL.RESERVES.ID, R.REDO.CCRG.TECHNICAL.RESERVES, YERR )
    IF YERR THEN
        CUST.OUT = YERR
        RETURN
    END ELSE
        CUST.OUT = R.REDO.CCRG.TECHNICAL.RESERVES<REDO.CCRG.TR.TECH.RES.AMOUNT>
    END

RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    FN.REDO.CCRG.TECHNICAL.RESERVES = 'F.REDO.CCRG.TECHNICAL.RESERVES'
    F.REDO.CCRG.TECHNICAL.RESERVES = ''

    FN.REDO.CCRG.RISK.LIMIT.PARAM = 'F.REDO.CCRG.RISK.LIMIT.PARAM'
    F.REDO.CCRG.RISK.LIMIT.PARAM = ''

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.REDO.CCRG.RISK.LIMIT.PARAM,F.REDO.CCRG.RISK.LIMIT.PARAM)

RETURN
*------------
END
