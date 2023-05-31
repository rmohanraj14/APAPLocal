* @ValidationCode : MjotMTAzMTM1ODczMjpDcDEyNTI6MTY4MDA3MTA4MTkyMTpJVFNTOi0xOi0xOjA6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.UPGRD.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG)
*---------------------------------------------------------------------------
*DESCRIPTION:
*------------
* Routine to extract arrangement condition record
*----------------------------------------------------------------------------
** Input/Output:
*      IN : ARR.ID - (Arrangement ID)
*           EFF.DATE - Effective Date
*           PROP.CLASS - Property Class
*           PROPERTY - Property
*     OUT : R.Condition - Arrangement Condition
*           ERR.MSG - Error message if any, else blank
*----------------------------------------------------------------------------
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*  Date                 who                            Reference                      Description
* 18-05-2017            Edwin Charles                  PACS00585816                  Initial Creation
** 30-03-2023 R22 Auto Conversion
** 30-03-2023 Skanda R22 Manual Conversion - No changes

*--------------------------------------------------------------------------
*--------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.PAYMENT.SCHEDULE

    GOSUB INITIALISE
    GOSUB GET.ARRANGEMENT.CONDITION

RETURN
*---------(Main)

INITIALISE:
*----------
    ArrangementID = ARR.ID
    idPropertyClass = PROP.CLASS
    idProperty = PROPERTY
    effectiveDate = EFF.DATE
    returnIds = ''
    returnConditions = ''
    returnError = ''
    returnVal = ''
    returnFreq = ''
    EngFreq = ''
    PayType = ''
    PAYMENT.TYPE = ''
    SHORT.TYPE = ''
    RTN.MSG = ''

    R.Arrangement = ''
    R.Err = ''

    IF effectiveDate EQ '' THEN ;** R22 Auto Conversion
        effectiveDate = TODAY
    END
RETURN
*---------(Initialise)

* Call AA.GET.ARRANGEMENT.CONDITIONS to get the arrangement condition record
GET.ARRANGEMENT.CONDITION:
*-------------------------

    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
    IF returnError THEN
        RTN.MSG = returnError
        RETURN
    END
* PACS00585816 - start
    R.Condition = returnConditions
* PACS00585816 - End
RETURN
*---------(GetPaymentType)
END
