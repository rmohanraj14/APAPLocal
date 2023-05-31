$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.R.BULK.MAN.RESPONSE(Y.TXN.COMMITED, Y.OFS.RESPONSE, Y.OUT.ERR.MSG)
*-----------------------------------------------------------------------------
** Allows to process the answer gotten from BULK.MANAGER when the TXN was not committed
* @author hpasquell@temenos.com
* @stereotype subroutine
* @package redo.fc
*!
*---------------------------------------------------------------------------------
*Modification History
*Date           Who                   Reference                                 Descripition
* 29-03-2023     Samaran T            Manual R22 Code Conversion                Package Name Added APAP.AA
* 29-03-2023 Conversion Tool        Auto R22 Code Conversion                   FM TO @FM , = TO EQ
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_AA.APP.COMMON
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
PROCESS:
* Process the OFS result and return the answer as a Dynamic.Array on Y.OUT.ERR.MSG
*-----------------------------------------------------------------------------
    IF NOT(Y.TXN.COMMITED) THEN

        Y.OUT.ERR.MSG = ''

* Change '</request><request>' to FMs
        CHANGE cTxn_REQUEST_TAG_C : cTxn_REQUEST_TAG TO @FM IN Y.OFS.RESPONSE

* Remove '<requests><request>'
        CHANGE cTxn_REQUESTS_TAG : cTxn_REQUEST_TAG TO '' IN Y.OFS.RESPONSE

* Remove '</request></requests>'
        CHANGE cTxn_REQUEST_TAG_C : cTxn_REQUESTS_TAG_C TO '' IN Y.OFS.RESPONSE

        NO.MSGS = DCOUNT(Y.OFS.RESPONSE,@FM)

        ERR.SRC = '' ; Y.OUT.ERR.MSG = ''

        FOR RCNT = 1 TO NO.MSGS

            HEADER.DET = FIELD(Y.OFS.RESPONSE<RCNT>,',',1,1)

            RESP.TAG = FIELD(HEADER.DET,'/',3,1)

            IF RESP.TAG EQ -1 THEN ;*AUTO R22 CODE CONVERSION

                ID.DETAILS = FIELD(HEADER.DET,'/',1,1)

                ERR.SOURCE = FIELD(ID.DETAILS,AA$SEP,2,1)
                IF NOT(ERR.SOURCE) THEN
                    ERR.SOURCE = ID.DETAILS
                END
                LOCATE ERR.SOURCE IN ERR.SRC<1,1> SETTING EPOS ELSE ;* Any subsequent errors could be the result of a previous error. Dont confuse users
                    ERR.SRC<1,-1> = ERR.SOURCE
                    Y.OUT.ERR.MSG<1,-1> = FIELD(Y.OFS.RESPONSE<RCNT>,',',2,99)
                END

            END
        NEXT RCNT
    END
RETURN
*-----------------------------------------------------------------------------
INITIALISE:

RETURN

END
