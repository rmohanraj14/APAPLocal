$PACKAGE APAP.AA ;*R22 Manual Code  Conversion
SUBROUTINE DR.REG.RIEN5.AA.ACC.EXT.SELECT
*-----------------------------------------------------------------------------
* Company Name   : APAP
* Developed By   : gangadhar@temenos.com
* Program Name   : DR.REG.RIEN5.AA.ACC.EXT.SELECT
* Date           : 3-Jun-2013
*-----------------------------------------------------------------------------
* Description:
*------------
* This multi-thread job is meant for to extact the AZ.ACCOUNT Details product wise.
*-----------------------------------------------------------------------------
*
* Modification History :
*
* ----------------------
*   Date          Author              Modification Description
* 05/10/2014  Ashokkumar.V.P            PACS00309203 - Added credit lines loan. Removed Account selection and
*                                        replaced with AA.ARRANGEMENT.
* 26/02/2015  Ashokkumar.V.P            PACS00309203 - Just for compilation
* 18/03/2015  Ashokkumar.V.P            PACS00309203 - Removed the concat file clearing.
* 27/03/2015  Ashokkumar.V.P            PACS00309203 - Performance change
* 16/04/2015  Ashokkumar.V.P            PACS00309203 - Performance change
*
*
* Date                  Who                               Reference                            Description
* ----                  ----                                ----                              ----
* 29-March-2023          Ajith Kumar             R22 Manual Code Conversion                Package Name added APAP.AA
* 29-March-2023       Conversion Tool                           R22 Auto Code Converson                      No Change
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_DR.REG.RIEN5.AA.ACC.EXT.COMMON
 
    IF NOT(CONTROL.LIST) THEN
        GOSUB BUILD.CONTROL.LIST
    END

    GOSUB SEL.PROCESS

RETURN

*-----------------------------------------------------------------------------
BUILD.CONTROL.LIST:
*******************

    CALL EB.CLEAR.FILE(FN.DR.REG.RIEN5.REP1,F.DR.REG.RIEN5.REP1)
    CALL EB.CLEAR.FILE(FN.DR.REG.RIEN5.REP2,F.DR.REG.RIEN5.REP2)
    CALL EB.CLEAR.FILE(FN.DR.REG.RIEN5.REP3,F.DR.REG.RIEN5.REP3)

    CONTROL.LIST<-1> = "REP1"

RETURN
*-----------------------------------------------------------------------------
SEL.PROCESS:
************

    LIST.PARAMETER = ""

    BEGIN CASE

        CASE CONTROL.LIST<1,1> EQ "REP1"
            LIST.PARAMETER<2> = "F.AA.ARRANGEMENT"
*        LIST.PARAMETER<3> = "START.DATE LE ":LAST.WORK.DAY
*        LIST.PARAMETER<3> := " AND PRODUCT.GROUP EQ ":PROD.GRP
            LIST.PARAMETER<3> := "PRODUCT.LINE EQ ":"LENDING"
*        LIST.PARAMETER<3> := " AND ((ARR.STATUS EQ ":"CURRENT":") OR (ARR.STATUS EQ ":"EXPIRED":"))"
            CALL BATCH.BUILD.LIST(LIST.PARAMETER, "")
        CASE 1
            DUMMY.LIST = ""
            CALL BATCH.BUILD.LIST("",DUMM.LIST)
    END CASE

RETURN
*-----------------------------------------------------------------------------
END
