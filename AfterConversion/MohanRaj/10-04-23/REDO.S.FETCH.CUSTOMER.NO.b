* @ValidationCode : MjozMDYyOTc3Mjg6Q3AxMjUyOjE2ODExMTUzNDgzOTI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:59:08
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
SUBROUTINE REDO.S.FETCH.CUSTOMER.NO(CUSTOEMR.NO)

*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This routine is attached in DEAL.SLIP.FORMAT to fetch custoemr no
*------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : KAVITHA
* PROGRAM NAME : REDO.S.FETCH.CUSTOMER.NO
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 8-Apr-2011       S KAVITHA           ODR-2010-03-0400    INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    CUSTOMER.NO = FIELD(CUSTOMER.NO,@VM,1)

RETURN
