* @ValidationCode : Mjo5NjEzMjk2MTA6Q3AxMjUyOjE2ODAxODQ2NzIwNzE6SVRTUzotMTotMTotMTc6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -17
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG)
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
*  Date                who                            Reference                      Description
* 23-Sep-2009     Mohammed Aslam        BPCRA2009090099         Initial Creation
*--------------------------------------------------------------------------
*--------------------------------------------------------------------------
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*
*------------------------------------------------------------------------
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
    IF effectiveDate EQ '' THEN ;*AUTO R22 CODE CONVERSION - Changed = to EQ
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
    R.Condition = RAISE(returnConditions)
RETURN
*---------(GetPaymentType)
END
