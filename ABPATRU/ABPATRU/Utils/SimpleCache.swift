/*
 *
    Proj: ABPATRU
    Author: Adi Pslr < adipislaru97@gmail.com >
    Date: 9 May 2018
 *
 */

import Foundation

public protocol SimpleCacheInterface
{
    var ramCache: SimpleCacheProvider { get set }
    var diskCache: SimpleCacheProvider? { get set }
    
    subscript( key: String ) -> Data? { get set }
}

public protocol SimpleCacheProvider
{
    func load( key: String ) -> Data?
    func save( key: String, value: NSData? )
}

public class SimpleCache: SimpleCacheInterface
{
    static let cache = SimpleCache( )
    
    private init( ) { }
    
    public static let shared: SimpleCacheInterface = SimpleCache( )
    
    public var ramCache: SimpleCacheProvider = RamCache( )
    public var diskCache: SimpleCacheProvider? = DiskCache( cacheDir: "SimpleCache" )
    
    public subscript( key: String ) -> Data?
    {
        get
        {
            guard let result = ramCache.load( key: key )
                else
            {
                if let file = diskCache?.load( key: key )
                {
                    return file
                }
                
                return nil
            }
            
            return result
        }
        
        set
        {
            let data: NSData? = newValue as NSData?
            
            ramCache.save( key: key, value: data )
            diskCache?.save( key: key, value: data )
        }
    }
    
}

public class RamCache: SimpleCacheProvider
{
    private let RAMCacheSeconds = 10 * 60
    
    private let cache: NSCache< NSString, NSData > = NSCache< NSString, NSData >( )
    
    public func load( key: String ) -> Data?
    {
        let checktstamp = cache.object( forKey: NSString( string: "SimpleCacheLastUpdateRAM" ) ) as Data?
        
        if( ( checktstamp ) != nil )
        {
            let oldStampStr = String( data: checktstamp!, encoding: .utf8 )
            let oldStamp = UInt64( oldStampStr! )
            let actualStamp = UInt64( floor( NSDate( ).timeIntervalSince1970 ) )
            
            if( ( actualStamp - oldStamp! ) < RAMCacheSeconds )
            {
                return cache.object( forKey: NSString( string: key ) ) as Data?
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    public func save( key: String, value: NSData? )
    {
        if let new = value
        {
            self.cache.setObject( new, forKey: NSString( string: key ) )
            
            let timestamp = String( UInt64( floor( NSDate( ).timeIntervalSince1970 ) ) ).data( using: .utf8 )
            
            self.cache.setObject( timestamp! as NSData, forKey: NSString( string: "SimpleCacheLastUpdateRAM" ) )
        }
        else
        {
            self.cache.removeObject( forKey: NSString( string: key ) )
        }
    }
}

public class DiskCache: SimpleCacheProvider
{
    private let DiskCacheSeconds = 30 * 60
    
    private let cacheDirectory: String
    
    init( cacheDir: String )
    {
        cacheDirectory = cacheDir
    }
    
    public func load( key: String ) -> Data?
    {
        guard let path = fileURL( fileName: key )
            else
        {
            return nil
        }
        
        guard let updatepath = fileURL( fileName: "SimpleCacheLastUpdateDisk" )
            else
        {
            return nil
        }
        
        var data: Data?
        var dataex: Data?
        
        do
        {
            dataex = try Data( contentsOf: updatepath )
        }
        catch { }
        
        if( ( dataex ) != nil )
        {
            let oldStampStr = String( data: dataex!, encoding: .utf8 )
            let oldStamp = UInt64( oldStampStr! )
            let actualStamp = UInt64( floor( NSDate( ).timeIntervalSince1970 ) )
            
            if( ( actualStamp - oldStamp! ) < DiskCacheSeconds )
            {
                do
                {
                    data = try Data( contentsOf: path )
                }
                catch { }
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
        
        return data
    }
    
    public func save( key: String, value: NSData? )
    {
        guard let path = fileURL( fileName: key )
            else
        {
            return
        }
        
        guard let updatepath = fileURL( fileName: "SimpleCacheLastUpdateDisk" )
            else
        {
            return
        }
        
        if let new = value as Data?
        {
            do
            {
                try new.write( to: path, options: .atomic )
                
                let timestamp = String( UInt64( floor( NSDate( ).timeIntervalSince1970 ) ) ).data( using: .utf8 )
                let tdata = timestamp! as NSData
                
                try tdata.write( to: updatepath, options: .atomic )
            }
            catch { }
        }
        else
        {
            try? FileManager.default.removeItem( at: path )
        }
    }
    
    private func fileURL( fileName name: String ) -> URL?
    {
        guard let escapedName = name.addingPercentEncoding( withAllowedCharacters: .alphanumerics )
            else
        {
            return nil
        }
        
        var cachesDir: URL?
        do
        {
            cachesDir = try cachesDirectory( )
        }
        catch
        {
            return nil
        }
        
        return cachesDir?.appendingPathComponent( escapedName )
        
    }
    
    private func cachesDirectory( ) throws -> URL?
    {
        var cachesDir: URL? = nil
        
        do
        {
            cachesDir = try FileManager .default
                .url( for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true )
                .appendingPathComponent( cacheDirectory, isDirectory: true )
        }
        catch
        {
            throw error
        }
        
        guard let dir = cachesDir
            else
        {
            return nil
        }
        
        do
        {
            try FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true, attributes: nil )
        }
        catch
        {
            throw error
        }
        
        return dir
    }
}
