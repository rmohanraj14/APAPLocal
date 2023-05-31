* @ValidationCode : MjotNDUzOTY2OkNwMTI1MjoxNjgwMTkwMTYwMTk5OklUU1M6LTE6LTE6NzY6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 76
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.PRODUCT(AA.ID, AA.ARR)
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
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - F TO CACHE
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes

*-----------------------------------------------------------------------------------



    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.PRODUCT

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    CALL CACHE.READ(FN.AA.PRODUCT, Y.PROD.ID, R.AA.PRODUCT, "")   ;** R22 Auto conversion - F.AA.PRODUCT,"" TO  R.AA.PRODUCT, "", F TO CACHE
    AA.ARR=R.AA.PRODUCT<AA.PDT.DESCRIPTION>
RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    Y.ARRG.ID = AA.ID
    Y.PROD.ID = AA.ARR<AA.ARR.PRODUCT>
    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    R.AA.PRODUCT = ''
    AA.ARR = 'NULO'
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)
RETURN
*------------
END
