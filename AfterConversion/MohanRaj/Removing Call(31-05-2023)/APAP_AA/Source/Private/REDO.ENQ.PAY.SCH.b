* @ValidationCode : Mjo5MTA2ODIzNzE6Q3AxMjUyOjE2ODAxODQ2NzMxMzU6SVRTUzotMTotMToxOTM6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 193
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.ENQ.PAY.SCH(OUT.DATA)
*---------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : Shankar Raju
*---------------------------------------------------------
* Description : This nofile rouitne is used to pass the customer value from the common variable and get the account number
*----------------------------------------------------------
* Linked With : Enquiry REDO.APAP.NATURAL.AND.LEGAL.PROSP
* In Parameter : ENQ.DATA
* Out Parameter : ENQ.DATA
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*----------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.APP.COMMON

    GOSUB PROCESS

RETURN

********
PROCESS:
*********

    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT = ''
    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)

    VAR.CUS.ID = AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.CUSTOMER>

    CALL F.READ(FN.CUSTOMER.ACCOUNT,VAR.CUS.ID,R.CUS.ACC,F.CUSTOMER.ACCOUNT,CUS.ERR)

    CHANGE @FM TO @VM IN R.CUS.ACC
    OUT.DATA = R.CUS.ACC

RETURN
END
