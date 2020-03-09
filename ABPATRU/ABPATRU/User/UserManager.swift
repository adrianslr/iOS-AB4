/*
 *
    Proj: ABPATRU
    Author: Adi Pslr < adipislaru97@gmail.com >
    Date: 9 May 2018
 *
 */

import Foundation

class UserManager
{
    static var userArr = [ User ]( )
    
    static var Cache = SimpleCache.cache
    
    static func clearArr( ) -> Void
    {
        userArr = [ User ]( )
    }
    
    static func loadUsers( completionBlock: @escaping ( Array< User > ) -> Void ) -> Void
    {
        let cachedData: Data? = Cache[ "SOusers" ]
        
        if( ( cachedData ) != nil )
        {
            do
            {
                let dictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData( cachedData! ) as! NSDictionary
                
                self.innerLoad( dictionary: dictionary, type: false )
                {
                    ( ) in
                    
                    completionBlock( userArr )
                }
            }
            catch { }
        }
        else
        {
            if !Network.isConnectedToNetwork( )
            {
                completionBlock( [ User ]( ) )
                
                return
            }
            
            self.clearArr( )
            
            Network.fetch( urlParam: "https://api.stackexchange.com/2.2/users?pagesize=10&order=desc&sort=reputation&site=stackoverflow" )
            {
                ( dictionary ) in
                
                let dataDict: Data = NSKeyedArchiver.archivedData( withRootObject: dictionary )
                
                Cache[ "SOusers" ] = dataDict
                
                self.innerLoad( dictionary: dictionary, type: true )
                {
                    ( ) in
                    
                    completionBlock( userArr )
                }
            }
        }
    }
    
    static private func innerLoad( dictionary: NSDictionary, type: Bool, completionBlock: @escaping ( ) -> Void ) -> Void
    {
        if( userArr.count != 0 )
        {
            completionBlock( )
            
            return
        }
        
        if let usersArray = dictionary.value( forKey: "items" ) as? NSArray
        {
            let group = DispatchGroup( )
        
            for usr in usersArray
            {
                if let usrDict = usr as? NSDictionary
                {
                    let id: Int = usrDict.value( forKey: "account_id" ) as! Int
                    var img: Data = "".data( using: .utf8 )!
                    let name: String = ( usrDict.value( forKey: "display_name" ) as! String )
                    let location: String = "🌏 " + ( usrDict.value( forKey: "location" ) as! String )
                    
                    var badges: String = ""
                    
                    if let bdgDict = usrDict.value( forKey: "badge_counts" ) as? NSDictionary
                    {
                        let bronzeb = String( format: "%@", bdgDict.value( forKey: "bronze" ) as! CVarArg )
                        let silverb = String( format: "%@", bdgDict.value( forKey: "silver" ) as! CVarArg )
                        let goldb = String( format: "%@", bdgDict.value( forKey: "gold" ) as! CVarArg )
                        
                        badges = "🏆 " + goldb + " | 🥈 " + silverb + " | 🥉 " + bronzeb
                    }
                    
                    if( type == true )
                    {
                        group.enter( )
                        
                        Network.getDataFromUrl( url: NSURL( string: usrDict.value( forKey: "profile_image" ) as! String )! as URL )
                        {
                            ( data ) in
                            
                            Cache[ "ab4_image_" + String( usrDict.value( forKey: "account_id" ) as! Int ) ] = data!
                            
                            img = data!
                            
                            userArr.append( User( id: Int( id ),
                                                  img: img,
                                                  name: name,
                                                  location: location,
                                                  badges: badges ) )
                            
                            group.leave( )
                        }
                    }
                    else
                    {
                        img = Cache[ "ab4_image_" + String( usrDict.value( forKey: "account_id" ) as! Int ) ]!
                        
                        userArr.append( User( id: Int( id ),
                                              img: img,
                                              name: name,
                                              location: location,
                                              badges: badges ) )
                    }
                }
            }
            
            if( type == true )
            {
                group.notify( queue: .main )
                {
                    completionBlock( )
                }
            }
        }
        
        if( type == false )
        {
            completionBlock( )
        }
    }
}

