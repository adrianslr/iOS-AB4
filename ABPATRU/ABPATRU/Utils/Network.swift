/*
 *
    Proj: ABPATRU
    Author: Adi Pslr < adipislaru97@gmail.com >
    Date: 9 May 2018
 *
 */

import SystemConfiguration
import Foundation

public class Network
{
    class func getDataFromUrl( url: URL, completion: @escaping ( Data? ) -> ( ) )
    {
        URLSession.shared.dataTask( with: url )
        {
            data, response, error in
            
            completion( data )
        }.resume( )
    }
    
    class func fetch( urlParam: String, completionBlock: @escaping ( NSDictionary ) -> Void ) -> Void
    {
        let url = NSURL( string: urlParam )
        
        URLSession.shared.dataTask( with: ( url as URL? )!, completionHandler: { ( data, response, error ) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject( with: data!, options: .allowFragments ) as? NSDictionary
            {
                completionBlock( jsonObj! )
            }
        }).resume( )
    }
    
    class func isConnectedToNetwork( ) -> Bool
    {
        var zeroAddress = sockaddr_in( sin_len: 0,
                                       sin_family: 0,
                                       sin_port: 0,
                                       sin_addr: in_addr( s_addr: 0 ),
                                       sin_zero: ( 0, 0, 0, 0, 0, 0, 0, 0 )
        )
        
        zeroAddress.sin_len = UInt8( MemoryLayout.size( ofValue: zeroAddress ) )
        zeroAddress.sin_family = sa_family_t( AF_INET )
        
        let defaultRouteReachability = withUnsafePointer( to: &zeroAddress )
        {
            $0.withMemoryRebound( to: sockaddr.self, capacity: 1 )
            {
                zeroSockAddress in SCNetworkReachabilityCreateWithAddress( nil, zeroSockAddress )
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags( rawValue: 0 )
        
        if( SCNetworkReachabilityGetFlags( defaultRouteReachability!, &flags ) == false )
        {
            return false
        }
        
        let isReachable = ( flags.rawValue & UInt32( kSCNetworkFlagsReachable ) ) != 0
        let needsConnection = ( flags.rawValue & UInt32( kSCNetworkFlagsConnectionRequired ) ) != 0
        let ret = ( isReachable && !needsConnection )
        
        return ret
    }
}
