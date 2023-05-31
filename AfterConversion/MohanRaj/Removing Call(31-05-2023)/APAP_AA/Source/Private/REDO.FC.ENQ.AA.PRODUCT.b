* @ValidationCode : MjotMTY5ODIyMDAxMzpDcDEyNTI6MTY4MDE4NDY3MzQ3OTpJVFNTOi0xOi0xOi0zNjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -36
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.ENQ.AA.PRODUCT(ENQ.DATA)
*
* ====================================================================================
*

*
* ====================================================================================
*
* Subroutine Type :Build Routine
* Attached to     :REDO.FC.AA.PRODUCT ENQUIRY
* Attached as     :Build routine attach to  field in REDO.FC.AA.PRODUCT enquiry
* Primary Purpose :Put de Description of the product in O.DATA to enquiry
*
*
* Incoming:
* ---------
*
*
*
* Outgoing:

* ---------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Bryan Torres (btorresalbornoz@temenos.com) - TAM Latin America
* Date            : Agosto 23 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES
*=======================================================================



    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

*
*************************************************************************
*

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

*
RETURN
*
* ======
PROCESS:

* ======



*LOCATE 'PRODUCT.GROUP' IN ENQ.DATA<2,1> SETTING POSSITION ELSE NULL
    ENQ.DATA<2,1>='PRODUCT.GROUP'

    ENQ.DATA<3,1>='EQ'

    ENQ.DATA<4,1>='CONSUMO HIPOTECARIO LINEAS.DE.CREDITO COMERCIAL'



RETURN


*
* =========
OPEN.FILES:
* =========
*

RETURN

* =========
INITIALISE:
* =========
*
    LOOP.CNT        = 1
    MAX.LOOPS       = 1
    PROCESS.GOAHEAD = 1

RETURN

* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*

*
RETURN
END
