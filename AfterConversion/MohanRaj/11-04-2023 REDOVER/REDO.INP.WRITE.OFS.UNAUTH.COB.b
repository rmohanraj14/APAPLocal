* @ValidationCode : MjotMTE3ODk4NDYzMjpDcDEyNTI6MTY4MTIxNDc2MzU1MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:36:03
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.INP.WRITE.OFS.UNAUTH.COB
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is an input routine which is attached to the version AA.ARRANGEMENT.ACTIVITY,REDO.COB
* Once after running the OFS.MESSAGE.SERVICE,The unauth record ACTIVITY id is written on
* Flat file AA.ACT.COB-"today " date is the file name
* FOR COB PROCESS
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who             Reference            Description
* 08-OCT-2010     Kishore.SP     ODR-2009-10-0325      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_GTS.COMMON
    $INSERT I_AA.ACTION.CONTEXT
*-----------------------------------------------------------------------------
*
*The ID of the record is written on the flat file
*
    AA.ACT.ID = ID.NEW
    FILE.NAME = 'TAM.BP'
    RECORD.NAME = "AA.ACT.COB"
    F.FILE.PATH = ''
*-----------------------------------------------------------------------------
*
*Open the file before doing the write process
*
    OPENSEQ FILE.NAME,RECORD.NAME TO F.FILE.PATH ELSE
        CREATE F.FILE.PATH THEN
        END
    END
*-----------------------------------------------------------------------------
*
*The ID is assigned to R.FLAT.FILE
*
    R.FLAT.FILE =AA.ACT.ID
*
* The new id is appended with the existing id's
*
    WRITESEQ R.FLAT.FILE APPEND TO F.FILE.PATH THEN
    END
RETURN
*-----------------------------------------------------------------------------
END
