$PACKAGE APAP.AA
SUBROUTINE REDO.COL.GET.LIMIT.AA(LIM.AA.ID,OUT.LIM.AA)
*-----------------------------------------------------------------------------
* Subroutine Type : ROUTINE
* Attached to     : COLLATERAL
* Attached as     : API ROUTINE
* Primary Purpose : IF RECEIVES LIKE INPUT AA.ID THEN RETURNS LIMIT.ID
*                   IF RECIEVES LIKE INPUT LIMIT ID THEN RETURNS AA.ID
* Incoming:
* ---------
* LIM.AA.ID<1> --> 'LIMITE' or 'AA.ID'
* LIM.AA.ID<2> --> Record.id
* Outgoing:
* ---------
* OUT.LIM.AA<1> --> LIMIT OR AA ID
*
* Error Variables:
*
*-----------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Jorge Valarezo - TAM Latin America
* Date            : February 25 2013
*
* Development for : PACS00568559
* Development by  : Silambarasan S - 3MS 
* Date            : February 9 2017
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023   Conversion Tool                R22 Auto Conversion  - VM to @VM , FM to @FM and SM to @SM 
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes 
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.LIMIT
* PACS00329804 - S
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
* PACS00329804 - E
    IF LIM.AA.ID<1> NE 'LIMITE' AND LIM.AA.ID<1> NE 'AA.ID' THEN
        OUT.LIM.AA = 'ERROR'
        RETURN
    END
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

* =========
INITIALISE:
* =========
    FN.LIMIT = 'F.LIMIT'
    F.LIMIT = ''
    R.LIMIT = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''

    FN.AA.ARR.LIMIT = 'F.AA.ARR.LIMIT'
    F.AA.ARR.LIMIT = ''
    R.AA.ARR.LIMIT = ''
* PACS00329804 - S
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''

    Y.AA.ID = LIM.AA.ID<2>
    Y.ARR.DATE = ''
* PACS00329804 - E
    REDO.AA.LIMIT.LIST = ''
    LIST.NAME.LIMIT = ''
    NO.OF.REC.LIMIT = ''
    Y.AA.LIMIT.ERR = ''
    REDO.AA.LIMIT.ID = ''
    Y.AA.LIMIT.POS = ''
    Y.ERR = ''
RETURN
* =========
OPEN.FILES:
* =========
    CALL OPF(FN.LIMIT,F.LIMIT)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.AA.ARR.LIMIT,F.AA.ARR.LIMIT)
    CALL OPF(FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)   ;* PACS00329804 - S/E

RETURN
* ======
PROCESS:
* ======
*

    GOSUB DEFINE.SELECT
    IF OUT.LIM.AA EQ 'ERROR' THEN
        RETURN
    END
*
    GOSUB GET.AA.LIMIT.DETAIL ;* PACS00329804 - S/E
*
    IF R.AA.ARR.LIMIT EQ "" THEN
        RETURN
    END
*
    Y.LIMIT.ID = R.AA.ARR.LIMIT<AA.LIM.LIMIT.REFERENCE>
*AA Changes 20161013
    Y.LIMIT.SERIAL = R.AA.ARR.LIMIT<AA.LIM.LIMIT.SERIAL>
*AA Changes 20161013
* PACS00329804 - S
    Y.ARR.ID = Y.AA.ID
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.ERR)
* PACS00329804 - E
    IF Y.ERR THEN
        OUT.LIM.AA = 'ERROR'
        RETURN
    END
    Y.LOAN.CUSTOMER = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
*AA Changes 20161013
*  Y.LIMIT.ID = FMT(Y.LIMIT.ID,'R2%10')
*    Y.LIMIT.ID = FMT(Y.LIMIT.ID,'R2%7')
    Y.LIMIT.ID = FMT(Y.LIMIT.ID,"7'0'R")
*  Y.LIMIT.ID = Y.LOAN.CUSTOMER:'.':Y.LIMIT.ID
    Y.LIMIT.ID = Y.LOAN.CUSTOMER:'.':Y.LIMIT.ID:'.':Y.LIMIT.SERIAL
*AA Changes 20161013
    CALL F.READ(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,Y.ERR)
    IF Y.ERR THEN
        OUT.LIM.AA = 'ERROR'
        RETURN
    END
*Devuelve como resultado lo opuesto a lo que envio
    IF LIM.AA.ID<1> EQ 'LIMITE' THEN
        OUT.LIM.AA = Y.ARR.ID
    END
    IF LIM.AA.ID<1> EQ 'AA.ID' THEN
        OUT.LIM.AA = Y.LIMIT.ID
    END
RETURN

*
*==============
GET.AA.DETAILS:
*==============
*
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ERR)
    Y.ARR.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BASE.DATE>
*
RETURN
*
*===================
GET.AA.LIMIT.DETAIL:
*===================
*
    PROPERTY.CLASS = 'LIMIT'
    R.AA.ARR.LIMIT = ''
*
    GOSUB GET.PROPERTY
    GOSUB GET.AA.CONDITIONS
*
    IF returnConditions THEN
        R.AA.ARR.LIMIT = returnConditions
    END
*
RETURN
*
*============
GET.PROPERTY:
*============
* Get the property Name for the property class
*
    ARR.INFO = Y.AA.ID ; R.ARRANGEMENT = '' ; AA.PROPERTY = '' ; CLASS.LIST = '' ; CLASS.CTR = '' ; PROP.LIST = ''
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.ARR.DATE, R.ARRANGEMENT, PROP.LIST)
    CALL AA.GET.PROPERTY.CLASS (PROP.LIST, CLASS.LIST)
    CLASS.LIST = RAISE(CLASS.LIST) ; PROP.LIST = RAISE(PROP.LIST)
    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ PROPERTY.CLASS THEN
            AA.PROPERTY = PROP.LIST<CLASS.CTR>
            RETURN
        END
    REPEAT
*
RETURN
*
*=================
GET.AA.CONDITIONS:
*=================
*
    Y.EFFEC.DATE = TODAY
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARR.INFO,PROPERTY.CLASS,AA.PROPERTY,Y.EFFEC.DATE,returnIds,returnConditions,returnError)
    CHANGE @VM TO @FM IN returnConditions
    CHANGE @SM TO @VM IN returnConditions
*
RETURN

*================
DEFINE.SELECT:
*===============

    IF LIM.AA.ID<1> EQ 'LIMITE' THEN
        Y.LIMIT.LEN = DCOUNT(LIM.AA.ID<2>,'.')

        IF Y.LIMIT.LEN EQ 3 THEN
            CALL F.READ(FN.LIMIT,LIM.AA.ID<2>,R.LIMIT,F.LIMIT,Y.ERR)
            IF Y.ERR THEN
                OUT.LIM.AA = 'ERROR'
                RETURN
            END
            Y.ID.LIMIT  = FIELD(LIM.AA.ID<2>,'.',2)
        END
        IF Y.LIMIT.LEN NE 2 THEN
            OUT.LIM.AA = 'ERROR'
            RETURN
        END
        SELECT.STATEMENT.LIMIT :=  " WITH LIMIT.REFERENCE EQ " : Y.ID.LIMIT
    END
    IF LIM.AA.ID<1> EQ 'AA.ID' THEN
        CALL F.READ(FN.AA.ARRANGEMENT,LIM.AA.ID<2>,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.ERR)
        IF Y.ERR THEN
            OUT.LIM.AA = 'ERROR'
            RETURN
        END
*
    END
RETURN
END
