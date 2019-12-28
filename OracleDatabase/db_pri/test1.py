#!/usr/bin/env python3

# insert/update/delete trx table in testdb instance
# cx_Oracle does have bulk insert/update method, but I want to create performance problem to database, so

""" trx table defination:
create table trx (
    trxid number(8),
    attr1 varchar2(10),
    attr2 varchar2(20),
    userid number(3),
    created date,
    updated date,
    constraint trx_pk primary key (trxid),
    constraint trx_nn_attr1 check (attr1 is not null),
    constraint trx_ck_attr2 check (attr1 in ('val1','val2', 'val3','val4')),
    constraint trx_nn_created check (created is not null),
    constraint trx_fk_user foreign key (userid) references users (userid)
);
"""

import cx_Oracle
import random

class Trx(cx_Oracle.Connection):
    # some class variables
    # put attr2 list to class variables, trx table defination has check constraint on this column
    attr2_vals  = ['val1','val2','val3','val4']
    row_limit   = 10          # limit of row return from select trx table
    dml_limit   = 10          # limit of insert, delete, update
    dml_max     = 10000       # max value you can overwrite
   
    def __init__(self, userid = 1):
        self.userid = userid
        cred = 'trx/trxpw@testdb_dga'
        #conn = super(Trx, self).__init__(cred)
        # row limit option available after 12.1
        #if conn.version > '12':
        #    self.row_limit = 100
        #return conn
        return super(Trx, self).__init__(cred)

    # alt-constructor, with pratise classmethod
#    @classmethod
#    def from_dblogin(cls, userid = 1, username, password, tnsname):
#        self.userid = userid
#        return super(Trx, username,password,tnsname)

    @classmethod
    def set_dml_limit(cls, limit):
        if limit > cls.dml_max:
            print("unable to overwrite dml_limit greater than dml_max")
        else:
            cls.dml_limit = limit

    # no much useful, just pratise
    def print_users(self):
        cur = self.cursor()
        cur.execute('select * from users')
        # using fetchall
        #rows = cur.fetchall()
        #for row in rows:
        #    print(row)
    
        # directly from cursor
        for row in cur:
            print(row)
        cur.close()


    def insert_trx(self, cnt = 1):
        if cnt > self.dml_limit:
            cnt = self.dml_limit
        cur = self.cursor()
        print(f"inserting { cnt }")
        stmt = """insert into trx 
        (trxid,attr1,attr2,userid,created) 
        values 
        (seq_trx.nextval, :attr1, :attr2, :userid, sysdate)
        """
        for i in range(cnt):
            param = { 
                "attr1": 'foo', 
                "attr2": random.sample(self.attr2_vals,1)[0], 
                "userid": self.userid 
                }
            cur.execute(stmt, param)
        cur.close()

    # update some random transaction
    def update_trx(self, cnt = 1):
        if cnt > self.dml_limit:
            cnt = self.dml_limit
        print(f"updating { cnt }")
        cur = self.cursor()
        stmt = """update trx set
        attr2 = :attr2,
        updated = sysdate
        where
        trxid = :trxid
        """
        for i in range(cnt):
            param = { 
                "attr2": random.sample(self.attr2_vals,1)[0], 
                "trxid": self.get_trxid(1)[0]
                }
            cur.execute(stmt, param)
        cur.close()

    # delete number of rows
    def delete_trx(self, cnt = 1):
        if cnt > self.dml_limit:
            cnt = self.dml_limit
        print(f"deleting { cnt }")
        cur = self.cursor()
        # convert to list of string
        trx_list = list(map(str,self.get_trxid(cnt)))
        # trxid is primary key, should use exists if it is from a subquery
        # however we need python to sample the list, still using "in"
        stmt = "delete from trx where trxid in (" + ','.join(trx_list) +")"
        cur.execute(stmt)
        cur.close()
 
    # pick random trx that is created by this user
    # return list of int
    def get_trxid(self, sample_cnt = 1):
        cur = self.cursor()
        stmt = "select trxid from trx where userid = :userid"
#        if self.dml_limit != None:
        if self.dml_limit > self.row_limit:
            stmt += " fetch first " + str(self.dml_limit) + " rows only"
        else:
            stmt += " fetch first " + str(self.row_limit) + " rows only"
        cur.execute(stmt, { "userid": self.userid })
        result = cur.fetchall()
        # dont use rowcount, it's for DML
        if len(result) < sample_cnt:
            # there's only one column selected, using position 0 for list compredension
            trxid=[ x[0] for x in result ]
        else:
            trxid=(random.sample([ x[0] for x in result ], sample_cnt))
        cur.close()
        return trxid


trx = Trx(2)
#trx = Trx.from_dblogin(2,'trx','trxpw','testdb_dga')
#trx.print_users()
trx.insert_trx(10)
trx.update_trx(3)
trx.delete_trx(5)
trx.set_dml_limit(100)
trx.delete_trx(100)
trx.commit()
trx.close()
