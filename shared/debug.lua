BennyCserviceDebug = BennyCserviceDebug or {}

function BennyCserviceDebug.Print(mMessage)
    if not Config or not Config.m_debug then
        return
    end

    print(('[benny-cservice] %s'):format(mMessage))
end

function BennyCserviceDebug.Warn(mMessage)
    if not Config or not Config.m_debug then
        return
    end

    print(('[benny-cservice] [WARN] %s'):format(mMessage))
end
