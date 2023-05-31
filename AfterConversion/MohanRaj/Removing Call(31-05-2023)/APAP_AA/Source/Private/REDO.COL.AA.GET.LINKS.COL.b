$PACKAGE APAP.AA

SUBROUTINE REDO.COL.AA.GET.LINKS.COL (Y.AA.ID,Y.COLL.INFO)
*-----------------------------------------------------------------------------
* Subroutine Type : ROUTINE
* Attached to     : COLLATERAL
* Attached as     : API ROUTINE
* Primary Purpose : GET COLLATERALS ID LINKED TO A PARTICULAR LOAN
* Incoming:
* ---------
* Y.AA.ID --> MUST BE AA VALID ID
* Outgoing:
* ---------
* Y.COLL.INFO<1> --> BALANACE OF AA
* Y.COLL.INFO<2> --> AMOUNT USED TO COVER THE LOAN
* Y.COLL.INFO<3> --> COLLATERAL DESCRIPTION
* Error Variables:
*
*-----------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Jorge Valarezo - TAM Latin America
* Date            : February 25 2013
* 31/OCT/2013     V.N. - Getting collateral ids from AA using APIs instead of SELECT.
* 29-MAR-2023   Conversion Tool             R22 Auto Conversion  - VM to @VM , FM to @FM and SM to @SM 
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes 
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.TERM.AMOUNT
* PACS00307565 -S
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
* PACS00307565 -E
    IF NOT(Y.AA.ID) THEN
        Y.AA.BAL = 'ERROR'
    END
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

* =========
INITIALISE:
* =========
    REDO.TERM.LIST = ''
    LIST.NAME.TERM = ''
    NO.OF.REC.TERM = ''
    Y.TERM.ERR = ''
    Y.TERM.ID = ''

    Y.FIELD = "L.AA.COL"
    Y.FIELD.COL.AMOUNT = "L.AA.COL.VAL"
    Y.FIELD.COL.DESC = 'L.AA.COL.DESC'
    Y.FIELD.AA.BAL = 'L.AA.AV.COL.BAL'    ;* PACS00307565 - S/E
    Y.FIELD.NAME = Y.FIELD:@VM:Y.FIELD.COL.AMOUNT:@VM:Y.FIELD.COL.DESC:@VM:Y.FIELD.AA.BAL      ;* PACS00307565 - S/E
    Y.POS = ''
    CALL MULTI.GET.LOC.REF("AA.PRD.DES.TERM.AMOUNT",Y.FIELD.NAME,Y.POS)
    Y.COLL.FIELD.POS = Y.POS<1,1>
    Y.COL.AMT.POS = Y.POS<1,2>
    Y.COL.DESC    = Y.POS<1,3>
    Y.AA.BALANCE  = Y.POS<1,4>  ;* PACS00307565 - S/E

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT  = ''
    Y.AA.COL.IDS = ''
    Y.AA.COL.AMT = ''
    Y.AA.BAL.AMT = ''
* PACS00307565 -S
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''
* PACS00307565 -E
RETURN

* =========
OPEN.FILES:
* =========
* PACS00307565 -S
    CALL OPF(FN.AA.ARR.TERM.AMOUNT, F.AA.ARR.TERM.AMOUNT)
    CALL OPF (FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)
* PACS00307565 -E
RETURN
*
* =========
PROCESS:
* =========
* PACS00307565 - S
    GOSUB GET.TERM.AMOUNT
*
    Y.AA.COL.IDS = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COLL.FIELD.POS>
    IF R.AA.ARR.TERM.AMOUNT EQ "" THEN
        Y.COLL.INFO = 'ERROR'
        RETURN
    END
* PACS00307565 - E
    CHANGE @SM TO @VM IN Y.AA.COL.IDS
    Y.AA.COL.AMT = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COL.AMT.POS>
    CHANGE @SM TO @VM IN Y.AA.COL.AMT
    Y.AA.COL.DES = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COL.DESC>
    CHANGE @SM TO @VM IN Y.AA.COL.DES
* PACS00307565 - S
    Y.AA.BAL.AMT = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.AA.BALANCE>
    CHANGE @SM TO @VM IN Y.AA.BAL.AMT
*
    IF Y.AA.COL.DES THEN
        Y.COLL.INFO = Y.AA.COL.IDS :@FM :Y.AA.COL.AMT :@FM :Y.AA.COL.DES :@FM :Y.AA.BAL.AMT
    END ELSE
        Y.NULL = ''
        Y.COLL.INFO = Y.AA.COL.IDS :@FM :Y.AA.COL.AMT :@FM :Y.NULL :@FM :Y.AA.BAL.AMT
* PACS00307565 - E
    END


RETURN

*======================
GET.AA.DETAILS:
*======================
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ERR)
    Y.ARR.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BASE.DATE>
RETURN

*==============
GET.PROPERTY:
*==============
* Get the property Name for the property class

    ARR.INFO = Y.AA.ID
    R.ARRANGEMENT = ''
    AA.PROPERTY = ''
    CLASS.LIST = ''
    CLASS.CTR = ''
    PROP.LIST = ''
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.ARR.DATE, R.ARRANGEMENT, PROP.LIST)
    CALL AA.GET.PROPERTY.CLASS (PROP.LIST, CLASS.LIST)
    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ PROPERTY.CLASS THEN
            AA.PROPERTY = PROP.LIST<CLASS.CTR>
            RETURN
        END
    REPEAT

RETURN

*====================
GET.AA.CONDITIONS:
*====================
    Y.EFFEC.DATE = TODAY
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARR.INFO,PROPERTY.CLASS,AA.PROPERTY,Y.EFFEC.DATE,returnIds,returnConditions,returnError)
    CHANGE @VM TO @FM IN returnConditions
    CHANGE @SM TO @VM IN returnConditions

RETURN

*=================
GET.TERM.AMOUNT:
*=================

    PROPERTY.CLASS = 'TERM.AMOUNT'
    R.AA.ARR.TERM.AMOUNT = ''
    GOSUB GET.PROPERTY
    GOSUB GET.AA.CONDITIONS
    IF returnConditions THEN
        R.AA.ARR.TERM.AMOUNT = returnConditions
    END

RETURN

END
