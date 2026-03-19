local utils = {}
function utils.printvec(v, msg)
    msg = msg.." " or ""
    print(msg.."(x: "..v.x.." y: "..v.y..")")
end

function utils.sign(x)
    return x > 0 and 1 or (x == 0 and 0 or -1)
end

return utils
