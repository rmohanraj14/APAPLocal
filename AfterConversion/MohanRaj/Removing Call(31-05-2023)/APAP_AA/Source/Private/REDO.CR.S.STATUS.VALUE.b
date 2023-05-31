* @ValidationCode : MjoxODEzMDk2MTc4OkNwMTI1MjoxNjg1NTI5ODEwNjg1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:13:30
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
$PACKAGE APAP.AA
SUBROUTINE REDO.CR.S.STATUS.VALUE
*
* ====================================================================================
*    - Set a Collateral rigth status Value refering to STATUS Core field
* ====================================================================================
*
* Subroutine Type : Input Routine
* Attached to     : Collateral.Right Versions
* Attached as     : Input Routine
* Primary Purpose :
*
*
* Incoming:
* ---------
* Outgoing:

*------------------------------------------------------------------------------------
* Modification History:
* Development for : Asociacion Popular de ahorros y Prestamos
* Development by  : Jorge Valarezo
* Date            : 28 Jan 2013
* 2013-JUN-18       V.N.L.        Override raising whenever LIMIT.REFERENCE value is
* removed, and current customer-collateral removed is the last one linked to the AA.
*=========================================================================
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED, Changed CALL format
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_AA.LOCAL.COMMON ;*
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS      ;*

*************************************************************************
*
*
    GOSUB INITIALISE
    GOSUB GET.LOCAL.FLDS.POS  ;* PACS00281659 - S
    GOSUB OPEN.FILES          ;* PACS00281659 - E
    GOSUB PROCESS
    GOSUB RAISE.OVE.UNLINK    ;* PACS00290578 - S/E
*
RETURN
*
* =========
INITIALISE:
* =========
*
    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT = ''
    R.CUSTOMER.ACCOUNT = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''

    FN.AA.ARR.LIMIT = 'F.AA.ARR.LIMIT'
    F.AA.ARR.LIMIT  = ''
*
* PACS00281659 - S
*Id Collateral.Rihgt
    Y.ID.COLLATERAL = ID.NEW : ".1"
    Y.LIM.REF.COUNT = ''
    Y.LIM.REF = ''
    Y.ID.CUSTOMER = ''
    Y.ID.LIMIT = ''
    NUM.AA.ID = 0
    NEW.LIMIT.REF = R.NEW(COLL.RIGHT.LIMIT.REFERENCE)
    OLD.LIMIT.REF = R.OLD(COLL.RIGHT.LIMIT.REFERENCE)
* PACS00281659 - E
*
* PACS00290578 - S
    WOLD.LINK = R.OLD(COLL.RIGHT.LIMIT.REFERENCE)
    WCUR.LINK = R.NEW(COLL.RIGHT.LIMIT.REFERENCE)
    CURR.NO = DCOUNT(R.NEW(COLL.RIGHT.OVERRIDE),@VM) + 1
* PACS00290578 - E
*
    Y.AA.ID.FND = ''
*
RETURN
*
*==================
GET.LOCAL.FLDS.POS:
*==================
* get local fields position from COLLATERAL.RIGHT
    Y.FIELD.CR  = "L.CR.ESTADO"
    Y.FIELD.NAME = Y.FIELD.CR
    Y.APPLICATION = "COLLATERAL.RIGHT"
    Y.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.FIELD.NAME,Y.POS)
    Y.POS.STAT = Y.POS<1,1>
*
RETURN
*
*==========
OPEN.FILES:
*==========
*
    CALL OPF(FN.AA.ARR.LIMIT, F.AA.ARR.LIMIT)
    CALL OPF(FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.CUSTOMER.ACCOUNT, F.CUSTOMER.ACCOUNT)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
*
RETURN
*
* ======
PROCESS:
* ======
    Y.STATUS.VALUE = R.NEW(COLL.RIGHT.STATUS)     ;*** Collateral Right Status
    R.NEW(COLL.RIGHT.LOCAL.REF)<1,Y.POS.STAT> = Y.STATUS.VALUE
*
RETURN
*
* ===============
RAISE.OVE.UNLINK:
* ===============
*
    IF WOLD.LINK NE "" AND WCUR.LINK EQ "" THEN
*
        Y.COLL.NUM = ''
        GOSUB GET.AA.LINKED   ;* PACS00281659 - S/E
*
        IF Y.COLL.NUM EQ 1 THEN
* PACS00308600 - S
*            CURR.NO = 0
*            TEXT = 'REDO.COLLR.UNLINK'
            TEXT = 'REDO.ASO.LOAN.LIMIT':@FM:Y.LIM.REF

* PACS00308600 - E
            CALL STORE.OVERRIDE(CURR.NO)
            CURR.NO = DCOUNT(R.NEW(COLL.RIGHT.OVERRIDE),@VM) + 1

        END
*
    END
*
RETURN
*
* ===========
GET.AA.LINKED:
* ===========
*
    GOSUB CHECK.LIMIT.REMOVED
    Y.LIM.REF.COUNT = DCOUNT(LIMIT.TO.REMOVED,@FM)
*
    IF Y.LIM.REF.COUNT LE 0 THEN
        RETURN
    END
*
    Y.ASOC.LN.OVR = ''

    ITR = 1
    LOOP
    WHILE ITR LE Y.LIM.REF.COUNT
        Y.LIM.REF = LIMIT.TO.REMOVED<ITR>
        Y.ID.CUSTOMER = FIELD(Y.LIM.REF,'.',1)
        Y.ID.LIMIT.AUX = FIELD(Y.LIM.REF,'.',2)
        Y.ID.LIMIT.AUX += 0 ;* AUTO R22 CODE CONVERSION
        Y.ID.LIMIT = Y.ID.LIMIT.AUX : "." : FIELD(Y.LIM.REF,'.',3)
*
* PACS00308600 - S
*        Y.ASOC.LN.OVR = ''
        GOSUB GET.CUSTOMER.ACCOUNTS
*        IF Y.ASOC.LN.OVR EQ 'Y' THEN
*            TEXT = 'REDO.ASO.LOAN.LIMIT':FM:Y.LIM.REF
*            CALL STORE.OVERRIDE('')
*        END
* PACS00308600 - E
*
        ITR += 1
    REPEAT
*
    ITR = 1
    LOOP
    WHILE ITR LE NUM.AA.ID
        GOSUB GET.COLL.AA.IDS ;* PACS00308600 - S/E
        ITR += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

*
RETURN
*
*===================
CHECK.LIMIT.REMOVED:
*===================
*
    LIMIT.TO.REMOVED = '' ; LIMIT.REF.POS = ''
    ITR = 1 ; OLD.LIMIT.NUM = DCOUNT(OLD.LIMIT.REF,@VM)
*
    LOOP
    WHILE ITR LE OLD.LIMIT.NUM
* PACS00308600 - S
*        LOCATE OLD.LIMIT.REF<ITR> IN NEW.LIMIT.REF SETTING LIMIT.REF.POS ELSE
*            LIMIT.TO.REMOVED<-1> = OLD.LIMIT.REF<ITR>
        LOCATE OLD.LIMIT.REF<1,ITR> IN NEW.LIMIT.REF SETTING LIMIT.REF.POS ELSE
            LIMIT.TO.REMOVED<-1> = OLD.LIMIT.REF<1,ITR>
* PACS00308600 - E
        END
        ITR += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
*
RETURN
*
*=====================
GET.CUSTOMER.ACCOUNTS:
*=====================
*
    CALL F.READ(FN.CUSTOMER.ACCOUNT,Y.ID.CUSTOMER,R.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT,Y.ERR)
    ITR.ACC = 1
    LOOP
    WHILE R.CUSTOMER.ACCOUNT<ITR.ACC>
        Y.ACC.ID = R.CUSTOMER.ACCOUNT<ITR.ACC>
        CALL F.READ(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT,YERR)
        IF R.ACCOUNT<AC.ARRANGEMENT.ID> THEN
            Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
*
            GOSUB GET.AA.DETAILS
            GOSUB GET.AA.LIMIT.DETAIL
*AA Changes 20161013
*      IF R.AA.ARR.LIMIT<AA.LIM.LIMIT.REFERENCE> EQ Y.ID.LIMIT THEN
            Y.LIMIT.REFER = R.AA.ARR.LIMIT<AA.LIM.LIMIT.REFERENCE>
            Y.LIMIT.SERIAL = R.AA.ARR.LIMIT<AA.LIM.LIMIT.SERIAL>
            Y.LIMI.CONCAT = Y.LIMIT.REFER:".":Y.LIMIT.SERIAL
            IF Y.LIMI.CONCAT EQ Y.ID.LIMIT THEN
*AA Changes 20161013
                AA.LINK.LIMIT<1,NUM.AA.ID>= Y.AA.ID         ;*Store all AA.ID from where will be removed all Collateral Ids
                AA.LINK.LIMIT<2,NUM.AA.ID>= Y.ARR.DATE      ;*Store all AA base date
                NUM.AA.ID += 1 ;* AUTO R22 CODE CONVERSION
* PACS00308600 - S
*                Y.ASOC.LN.OVR = 'Y'
* PACS00308600 - E
            END
        END
        ITR.ACC += 1 ;* AUTO R22 CODE CONVERSION
    REPEAT
*
RETURN
*
***************
GET.COLL.AA.IDS:
***************
*
    Y.AA.ID.FND = AA.LINK.LIMIT<1,NUM.AA.ID>
*
    COL.ID.LINKED = ''
    APAP.AA.RedoColAaGetLinksCol(Y.AA.ID.FND,COL.ID.LINKED);*MANUAL R22 CODE CONVERSION - Changed CALL format
    MMARK = CHARX(251) ;*AUTO R22 CODE CONVERSION
    IF COL.ID.LINKED EQ "ERROR" THEN
        COL.ID.LINKED = ''
    END
*
    COL.ID.LINKED = CHANGE(COL.ID.LINKED, MMARK , @VM )
*
    Y.CL.VM     = '' ; Y.CL.VM = DCOUNT(COL.ID.LINKED,@VM)
    Y.CL        = 1
    LOOP
    WHILE Y.CL LE Y.CL.VM
        Y.CL.ID = '' ; Y.CL.ID = COL.ID.LINKED<1,Y.CL,1>
        IF Y.CL.ID NE "" THEN
            Y.COLL.NUM += 1 ;* AUTO R22 CODE CONVERSION
        END
        Y.CL += 1 ;* AUTO R22 CODE CONVERSION
    REPEAT
*
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
*
END
