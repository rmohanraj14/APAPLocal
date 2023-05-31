* @ValidationCode : MjoxODY0NzAxNjQyOkNwMTI1MjoxNjgwMTg0NjczMzQ0OklUU1M6LTE6LTE6LTE1OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -15
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.AA.FLOW
*-------------------------------------------------------------------------------------------------
* Developer    : Marcelo Gudino
* Date         : 10.08.2011
* Description  : Register in a browser session the variables Customer and Product
*
*
*-------------------------------------------------------------------------------------------------
* Modification History:
*
* Version   Date            Who               Reference      Description
* 2.0       2011-06-15      MGUDINO          CR.180         HAND OPERATE
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHNAGES
*-------------------------------------------------------------------------------------------------
* Input/Output: NA
* Dependencies: NA
*-------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_System
    $INSERT I_F.REDO.CREATE.ARRANGEMENT


    GOSUB INIT
    GOSUB PROCESS

RETURN

*----------
INIT:
*----------

    Y.CUSTOMER.ID = R.NEW(AA.ARR.ACT.CUSTOMER)
    Y.PRODUCT = R.NEW(AA.ARR.ACT.PRODUCT)

RETURN

*------------
PROCESS:
*------------
    Y.VAR.BAND = 1
    CALL System.setVariable("CURRENT.CUSTOMER",Y.CUSTOMER.ID)
    CALL System.setVariable("CURRENT.PRODUCT",Y.PRODUCT)
    IF PGM.VERSION EQ ',AA.NEW.FC' THEN
        Y.VAR.BAND = 0
    END
    CALL System.setVariable("CURRENT.BAND",Y.VAR.BAND)

RETURN
*------------
END
