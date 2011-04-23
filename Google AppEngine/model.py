import datetime
import sys

from google.appengine.ext import db

FETCH_THEM_ALL = 10000

class Server(db.Model):

    Name = db.StringProperty(required = True)
    Password = db.StringProperty()
    bProtected = db.BooleanProperty(required=True, default=False)
    GameType = db.StringProperty()
    Maplist = db.ListProperty(db.Category)
    bRanked = db.BooleanProperty(required=True, default=False)
    IPAddr = db.StringProperty()
    Port = db.IntegerProperty()
    CurrentPlayers = db.IntegerProperty()
    MaxPlayers = db.IntegerProperty()
    Status = db.StringProperty(default="Online")
    UpdateTime = db.DateTimeProperty(auto_now_add = True)

    @classmethod
    def get_all(cls):
        q = db.Query(Server)
        q.order('-UpdateTime')
        return q.fetch(FETCH_THEM_ALL)

    @classmethod
    def get(cls, filterdict):
        q = db.Query(Server)

        for key in filterdict.keys():
            q.filter(str(key) + ' = ', str(filterdict[key]))
        
        if q.count() > 0:
            q.order('-UpdateTime')
        return q.fetch(limit=1000)

    def __unicode__(self):
        return self.__str__()

    def __str__(self):
        return '[%s] %s' %\
               (self.published_when.strftime('%Y/%m/%d %H:%M'), self.title)

    @classmethod
    def convertStringToMaplist(cls, maplist):
        new_maplist = []
        for map in maplist:
            if type(map) == db.Category:
                new_maplist.append(map)
            else:
                new_maplist.append(db.Category(unicode(map)))

        return new_maplist

    @classmethod
    def convertMaplistToString(cls, maplist):
        new_maplist = ",".join(maplist)
        return new_maplist

    def add(self):
        ExistingServer = Server.get(self.IPAddr)

        if ExistingServer:
            #Going from draft to published
            #Update the timestamp
            self.UpdateTime = datetime.datetime.now()

        self.put()
        
