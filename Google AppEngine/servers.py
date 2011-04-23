import cgi
import logging

from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

from model import *
import defs
import request

template_vars = {}

class ServerHandler(request.ServerRequestHandler):
    def get(self):
        GameType = cgi.escape(self.request.get('GameType'))
        sRanked = cgi.escape(self.request.get('bRanked'))
        bRanked = int(sRanked) if sRanked else 2
        sProtected = cgi.escape(self.request.get('bProtected'))
        bProtected = int(sProtected) if sProtected else 2
        sFilled = cgi.escape(self.request.get('bFilled'))
        bFilled = int(sFilled) if sFilled else 2
        sInGame = cgi.escape(self.request.get('bInGame'))
        bInGame = True if sInGame else False

        filterdict = {}
        if GameType:
            logging.debug("GameType filtration")
            filterdict['GameType'] = GameType
        if bRanked == 1:
            logging.debug("Ranked only")
            filterdict['bRanked'] = True
        elif bRanked == 0:
            logging.debug("Unranked only")
            filterdict['bRanked'] = False
        if bProtected == 1:
            logging.debug("Protected only")
            filterdict['bProtected'] = True
        elif bProtected == 0:
            logging.debug("Unprotected only")
            filterdict['bProtected'] = False
        if bFilled == 1:
            logging.debug("Filled only")
            filterdict['bFilled'] = True
        elif bFilled == 0:
            logging.debug("Unfilled only")
            filterdict['bFilled'] = False

        servers = Server.get(filterdict)
        template_vars['servers'] = servers
        if bInGame:
            for server in servers:
                Maplist = Server.convertMaplistToString(server.Maplist)
                retval = server.Name+","+str(server.bProtected)+","+server.GameType+","+Maplist+","+str(server.bRanked)+","+server.IPAddr+","+str(server.Port)+","+str(server.CurrentPlayers)+","+str(server.MaxPlayers)+","+server.Status
                self.response.out.write(retval)
        else:
            self.response.out.write(self.render_template('servers.html',
                                                     template_vars))

    def post(self):
        logging.debug("Post request made")
        Name = cgi.escape(self.request.get('Name'))
        Password = cgi.escape(self.request.get('Password'))
        bProtected = True if Password else False
        GameType = cgi.escape(self.request.get('GameType'))
        Maplist  = cgi.escape(self.request.get('Maplist'))
        IPAddr   = self.request.remote_addr
        s_Port   = cgi.escape(self.request.get('Port'))
        Port = int(s_Port) if s_Port else 32768             #find out what the default port is
        s_CurrentPlayers = cgi.escape(self.request.get('CurrentPlayers'))
        CurrentPlayers = int(s_CurrentPlayers) if s_CurrentPlayers else 0
        s_MaxPlayers = cgi.escape(self.request.get('MaxPlayers'))
        MaxPlayers = int(s_MaxPlayers) if s_MaxPlayers else 32
        s_bRanked = cgi.escape(self.request.get('bRanked'))
        bRanked = True if (s_bRanked == "True") else False

        if Maplist:
            Maplist = [map.strip() for map in Maplist.split(',')]
        else:
            Maplist = []
        Maplist = Server.convertStringToMaplist(Maplist)

        filterdict = {}
        if IPAddr:
            filterdict["IPAddr"] = IPAddr
            logging.debug("Looking for existing servers")
            servers = Server.get(filterdict)
        else:
            logging.error("No IPAddr detected")
            servers = []

        if len(servers) > 0:
            logging.debug("Existing server found")
            server = servers[0]
            server.Name = Name
            if Password:
                server.Password = Password
            server.bProtected = bProtected
            server.GameType = GameType
            server.CurrentPlayers = CurrentPlayers
            server.MaxPlayers = MaxPlayers
            server.Maplist = Maplist
            server.bRanked = bRanked
            server.Status = "Online"
        else:
            logging.debug("Making new server")
            server = Server(Name=Name,
                            Password=Password,
                            bProtected=bProtected,
                            GameType=GameType,
                            Maplist=Maplist,
                            CurrentPlayers=CurrentPlayers,
                            MaxPlayers=MaxPlayers,
                            IPAddr=IPAddr,
                            Port=Port)
        server.save()
        self.response.out.write("Server added");

application = webapp.WSGIApplication(
    [('/.*', ServerHandler)],
    debug=True)

def main():
    util.run_wsgi_app(application)

if __name__ == "__main__":
    main()

