*-----------------------------------------------------------------------------
$PACKAGE APAP.AA ;*R22 manual Code Conversion
SUBROUTINE DR.GET.AA.PROP.BALANCE(AA.ACC.ID,PROPERTY,R.AA.ARR.OVERDUE,OD.STATUS,INIT.STATUS,PROP.BALANCE,PROP.BAL.TYPES)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
*--------------------------------------------------------------------------------
* gets the balance type applicable to the arrangement and get the balance from ECB.
* Either the property or the balance types has to be passed to this routine.
* All applicable asset types are obtained by obtaining present overdue status of the arrangement.
* Author : Temenos USA.INC
* Incomming - AA.ACC.ID - Account id of the arrangement
*              Property - property from arrangement (all balance types for the property will be calculated)
*              R.AA.ARR.OVERDUE - OVERDUE record for the arrangement
*              OD.STATUS - The overdue status of the arrangement
*              PROP.BAL.TYPES - The balance types for which the balance has to be computed(only the passed bal type)
* Outgoing - Prop.Balance - The total balance of the property with all asset.types
*            PROP.BAL.TYPES - The balance type for the property which has a balance in ECB
*-----------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

* Modification History:
* Date                  Who                               Reference                             Description
* ----                  ----                                ----                                     ----
* 29-March-2023          Ajith Kumar          R22 Manual Code Conversion                      Package Name added APAP.AA
* 29-March-2023         Conversion Tool                      R22 Auto code conversion                             FM to @FM, ! to *
*-----------------------------------------------------------------------------------


    PROP.BALANCE = 0
    PROP.BAL.TYPES = ''
    ACCT.ID =  AA.ACC.ID
    SUB.TYPE = ''
    BAL.DATE = TODAY

    IF  PROP.BAL.TYPES EQ '' THEN
        GOSUB COMPUTE.TOT.BALANCE
    END ELSE
        GOSUB COMPUTE.BALTYP.TOTAL
    END

RETURN

COMPUTE.BALTYP.TOTAL:
*--------------------
    NO.OF.BAL =  DCOUNT(PROP.BAL.TYPES,@FM) ;*R22 Auto Code Conversion
    FOR IBALTYP = 1 TO NO.OF.BAL
        BALANCE.TYPE =  PROP.BAL.TYPES<IBALTYP>
        ECB.BALANCE  = '' ; ECB.BAL.LCY = ''
* call the core routine to get the balance from ECB ;*R22 Auto Code Conversion
        CALL AC.GET.ECB.BALANCE(ACCT.ID,BALANCE.TYPE,SUB.TYPE,BAL.DATE,ECB.BALANCE,ECB.BAL.LCY)
        IF ABS(ECB.BALANCE) GT 0 THEN
            PROP.BALANCE += ECB.BALANCE
        END
    NEXT IBALTYP

RETURN

COMPUTE.TOT.BALANCE:
*-------------------
    NO.OF.PROP =  DCOUNT(PROPERTY,@FM)
    FOR IPRP =  1 TO NO.OF.PROP
        PRES.PROP = PROPERTY<IPRP>
        LOCATE OD.STATUS IN R.AA.ARR.OVERDUE<AA.OD.OVERDUE.STATUS,1,1> SETTING ODSTSPOS THEN

            FOR IOD.STS = 1 TO ODSTSPOS
                IF R.AA.ARR.OVERDUE<AA.OD.MOVE.BALANCE,IOD.STS,1> EQ 'YES' THEN
                    BALANCE.TYPE =  R.AA.ARR.OVERDUE<AA.OD.OVERDUE.STATUS,IOD.STS,1> : PRES.PROP
                    ECB.BALANCE  = '' ; ECB.BAL.LCY = ''
* call the core routine to get the balance from ECB ;*R22 Auto Code Conversion
                    CALL AC.GET.ECB.BALANCE(ACCT.ID,BALANCE.TYPE,SUB.TYPE,BAL.DATE,ECB.BALANCE,ECB.BAL.LCY)
                    IF ABS(ECB.BALANCE) GT 0 THEN
                        PROP.BALANCE += ECB.BALANCE
                        PROP.BAL.TYPES<-1> =  BALANCE.TYPE
                    END
                END
            NEXT IOD.STS
        END
    NEXT IPRP
* The normal balance type
    BALANCE.TYPE =  INIT.STATUS : PRES.PROP
    ECB.BALANCE  = '' ; ECB.BAL.LCY = ''
    CALL AC.GET.ECB.BALANCE(ACCT.ID, BALANCE.TYPE, SUB.TYPE, BAL.DATE,ECB.BALANCE,ECB.BAL.LCY)
    IF ABS(ECB.BALANCE) GT 0 THEN
        PROP.BALANCE += ECB.BALANCE
        PROP.BAL.TYPES<-1> =  BALANCE.TYPE
    END
RETURN
