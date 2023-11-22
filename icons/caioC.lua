local screenW, screenH = guiGetScreenSize();
local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).

parentW, parentH = (347.04 * screenScale), (413.38 * screenScale); -- Comprimento e Largura do painel.
parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.

local function respX (x)
    return (parentX + (x * screenScale));
end
    
local function respY (y)
    return (parentY + (y * screenScale));
end
    
local function respC (scale)
    return (scale * screenScale);
end

local _dxDrawText = dxDrawText;
local function dxDrawText(text, x, y, width, height, ...)
    return _dxDrawText(text, respX(x), respY(y+(animationY or 0)), (respX(x) + respC(width)), (respY(y+(animationY or 0)) + respC(height)), ...);
end

local _dxDrawRectangle = dxDrawRectangle;
local function dxDrawRectangle(x, y, width, height, ...)
    return _dxDrawRectangle(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);
end

local _dxDrawImage = dxDrawImage;
local function dxDrawImage(x, y, width, height, ...)
    return _dxDrawImage(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);
end

local _dxDrawImageSection = dxDrawImageSection;
local function dxDrawImageSection(x, y, width, height, ...)
    return _dxDrawImageSection(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);
end

size = {}
local function dxDrawRounded (x, y, w, h, radius, ...)
    if not size[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        size[w..'.'..h..':'..radius] = svgCreate(w, h, svg)
    else
        dxDrawImage(x, y, w, h, size[w..'.'..h..':'..radius], 0, 0, 0, ...)
    end
end

local cursor = {}
local function isMouseInPosition (x, y, width, height, color)
    if (not cursor.state) then
        return false
    end
    if not (cursor.x and cursor.y) then
        return false;
    end
    if not color then
        x, y, width, height = respX(x), respY(y), respC(width), respC(height);
    end
    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));
end

local font = {}
local function getFont (name, size)
    if not font[name] then
        font[name] = {}
    end
    if not font[name][size] then
        font[name][size] = dxCreateFont('assets/fonts/'..name..'.ttf', respC(size/1.25))
    end
    return font[name][size]
end

function createEditbox (action, length, number)
    if action then
        if not edit then
            edit = {}
        end
        local editbox = guiCreateEdit(0, 0, 0, 0, '')
        if length then
            guiEditSetMaxLength(editbox, length)
            if number then
                guiSetProperty(editbox, 'ValidationString', '[0-9]*')
            end
        end
        edit[action] = editbox
    end
end

function removeEditbox (action)
    if action == 'all' then
        for _, v in pairs(edit) do
            if isElement(v) then
                destroyElement(v)
            end
        end
        edit = nil
    else
        if isElement(edit[action]) then
            destroyElement(edit[action])
            edit[action] = nil
        end
    end
end

function setEditboxEditing (action)
    if guiEditSetCaretIndex(edit[action], string.len(guiGetText(edit[action]))) then
        guiBringToFront(edit[action])
        guiSetInputMode('no_binds_when_editing')
        selectEditbox = action
    end
end

function getEditboxValue (action, drawing)
    if (drawing == true) then
        local editbox = guiGetText(edit[action])
        if selectEditbox == action then
            return editbox..'|'
        else
            return (editbox == '' and action or editbox)
        end
    else
        local editbox = guiGetText(edit[action])
        return editbox
    end
end

local _svgCreate = svgCreate;
local function svgCreate (width, height, ...)
    return _svgCreate((width*2), (height*2), ...)
end

local svg = {

    ['border'] = svgCreate(43, 25,
        [[
            <svg width="43" height="25" viewBox="0 0 43 25" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="1.03516" y="1.1792" width="40.9268" height="22.4278" rx="4.5" fill="white" fill-opacity="0.47" stroke="white"/>
            </svg>
        ]]
    ),

    ['icon'] = svgCreate(32, 32,
        [[
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.01865 0.217476C8.09904 0.557802 6.25982 1.63671 5.70227 2.17255C5.17367 2.66494 5.11575 3.1356 5.49952 3.96107C6.21638 5.53237 5.98467 7.19057 4.87679 8.40705C4.14545 9.21081 3.25481 9.63802 2.11073 9.7394C1.03906 9.84077 0.7639 10.1449 0.626321 11.4266C0.495983 12.5851 0.568393 14.323 0.7639 14.9312C0.923203 15.4163 1.50248 15.7567 2.1759 15.7567C3.24032 15.7567 4.56543 16.5097 5.20264 17.48C5.6733 18.1897 5.84709 18.711 5.88329 19.522C5.92674 20.3113 5.81812 20.8616 5.47055 21.6146C5.20988 22.165 5.18816 22.6356 5.3909 22.976C5.75295 23.5625 8.01215 24.9528 9.14175 25.2858C9.44587 25.3727 9.57621 25.38 9.8224 25.3148C10.1627 25.2207 10.3582 25.0396 10.8217 24.3807C11.0027 24.1273 11.3503 23.7725 11.6182 23.577C12.994 22.5415 14.7028 22.4691 16.209 23.3742L16.4841 23.5335L18.4537 21.564L20.4232 19.5944L20.4305 18.6386C20.4377 17.5235 20.5825 16.8863 21.0025 16.0391C21.7701 14.4967 23.0879 13.3961 24.7678 12.8892C25.3471 12.7155 25.5354 12.6937 26.4912 12.6937C27.4108 12.6865 27.5556 12.672 27.5556 12.5779C27.5556 12.1869 27.3963 10.7604 27.3384 10.5721C27.2515 10.3114 26.875 9.92766 26.5926 9.82629C26.4767 9.78284 26.245 9.74664 26.0712 9.74664C24.8765 9.74664 23.5296 8.99358 22.82 7.92191C22.4145 7.30642 22.248 6.77783 22.2118 5.92339C22.1756 5.07619 22.2407 4.7431 22.6028 3.94659C23.1024 2.83148 22.9214 2.44771 21.4153 1.44845C20.7346 0.992264 19.1705 0.210234 18.8157 0.145065C18.2437 0.0364494 17.8237 0.275404 17.3748 0.956059C16.8607 1.73085 15.9555 2.3753 15.0649 2.61425C14.5146 2.75183 13.5877 2.75183 13.0374 2.61425C12.1323 2.3753 11.1692 1.65119 10.5537 0.746069C10.1845 0.195753 9.61241 0.000244141 9.01865 0.217476ZM15.7166 7.74812C16.4696 8.0088 17.201 8.46498 17.7658 9.03702C18.2944 9.57286 18.4247 9.75388 18.7506 10.3983C19.1778 11.231 19.2647 11.6221 19.2574 12.7517C19.2574 13.6568 19.2357 13.8306 19.0619 14.3447C18.7868 15.1774 18.403 15.7856 17.7441 16.4446C16.7376 17.4511 15.6876 17.9217 14.2973 17.9869C13.3053 18.0304 12.6247 17.8855 11.6978 17.4438C11.1113 17.1614 10.923 17.0166 10.3582 16.4518C9.27932 15.3657 8.80142 14.2361 8.80142 12.7517C8.80142 10.3114 10.3655 8.28396 12.726 7.64675C13.5298 7.42952 14.9273 7.47296 15.7166 7.74812Z" fill="white"/>
                <path d="M25.6144 13.7292C23.7317 14.0696 22.2256 15.3657 21.6391 17.1687C21.4508 17.7552 21.3856 18.6748 21.4653 19.6162L21.4942 19.9637L17.6203 23.8522C15.028 26.4517 13.6884 27.842 13.5871 28.0447C13.3626 28.5009 13.3264 28.9136 13.4712 29.4133C13.5798 29.8043 13.6667 29.9129 14.398 30.6442C15.0497 31.2887 15.2815 31.4697 15.5639 31.5711C16.0128 31.7159 16.3531 31.7159 16.8093 31.5711C17.1279 31.4625 17.5479 31.0714 21.1177 27.5089L25.0641 23.5698L25.8968 23.6204C26.9974 23.6856 27.707 23.548 28.6411 23.0919C29.2059 22.8167 29.4304 22.6502 29.9155 22.165C30.4079 21.6726 30.56 21.4626 30.8351 20.8906C31.0162 20.5141 31.1972 20.0579 31.2406 19.8696C31.371 19.3193 31.4217 18.4649 31.3348 18.4069C31.2913 18.378 30.531 18.7762 29.6476 19.2831C28.0401 20.2099 28.0401 20.2099 27.5115 20.2317C26.5485 20.2823 25.8099 19.8624 25.4044 19.0369C24.9989 18.2042 25.2089 17.1108 25.8895 16.5387C26.0416 16.4084 26.8236 15.9233 27.6201 15.4671C28.6049 14.9023 29.0683 14.5982 29.0538 14.5257C29.0321 14.3737 28.2284 13.9899 27.6418 13.8378C27.0481 13.693 26.1212 13.6423 25.6144 13.7292Z" fill="white"/>
            </svg>
        ]]
    ),

    ['icon-infos'] = svgCreate(17, 16,
        [[
            <svg width="17" height="16" viewBox="0 0 17 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.55241 0.83709C10.3636 0.983375 11.1216 1.39563 11.6902 1.99739C13.03 3.41369 13.1164 5.59799 11.893 7.11735C10.2971 9.10216 7.24511 9.03567 5.72242 6.98104C5.15723 6.21969 4.88128 5.22895 4.98102 4.31135C5.08076 3.36715 5.45312 2.58253 6.1114 1.9176C6.66329 1.35906 7.40469 0.970077 8.16603 0.83709C8.50515 0.777247 9.22992 0.777247 9.55241 0.83709Z" fill="white"/>
                <path d="M5.04803 8.60345C5.58662 8.66662 6.25155 8.92262 6.71368 9.23513C6.98297 9.41799 7.37196 9.78702 7.57808 10.0596C7.79419 10.3456 8.08676 10.9374 8.18649 11.2997C8.4159 12.101 8.35605 12.9986 8.02691 13.76C7.56146 14.8372 6.67046 15.5952 5.49021 15.921C5.26745 15.9808 5.14112 15.9941 4.61582 15.9941C4.05063 15.9941 3.97417 15.9875 3.6683 15.9044C3.27931 15.798 2.81054 15.5819 2.47475 15.3492C2.18551 15.1497 1.77325 14.7407 1.56712 14.4482C1.34769 14.139 1.10167 13.607 1.00193 13.2314C0.888894 12.7992 0.862296 12.1143 0.938763 11.6688C1.20141 10.1594 2.39163 8.93591 3.87443 8.65332C4.22684 8.58683 4.74216 8.56355 5.04803 8.60345ZM4.28668 10.0829C3.84783 10.3023 3.76471 10.8443 4.11713 11.1933C4.46621 11.5458 5.00813 11.4626 5.22756 11.0238C5.37384 10.7246 5.33062 10.442 5.0979 10.2093C4.8685 9.97985 4.5859 9.93663 4.28668 10.0829ZM4.3831 11.8317C4.29998 11.8749 4.20024 11.958 4.16035 12.0212C4.08388 12.1309 4.08388 12.1508 4.08388 13.1782C4.08388 14.0359 4.09385 14.2387 4.13375 14.3185C4.24014 14.5246 4.51608 14.6477 4.74216 14.5878C4.89509 14.5446 5.0713 14.3717 5.11452 14.2155C5.15774 14.0692 5.15774 12.3104 5.11452 12.1575C5.058 11.9514 4.82195 11.7718 4.5992 11.7619C4.5593 11.7585 4.46289 11.7918 4.3831 11.8317Z" fill="white"/>
                <path d="M10.0673 9.23514C11.4437 9.35482 12.7503 9.69726 13.8076 10.2126C14.3561 10.4819 14.7917 10.7711 15.1474 11.1069C15.6029 11.5391 15.8589 11.9181 16.0218 12.4069C16.0982 12.6296 16.1016 12.6828 16.1016 13.5372V14.4349L16.0118 14.6244C15.8988 14.8671 15.686 15.0799 15.4333 15.2029L15.2372 15.2993L11.5501 15.3093L7.86308 15.3159L7.95285 15.2095C8.71419 14.272 9.07658 13.2347 9.02671 12.1243C8.98349 11.1202 8.62775 10.2026 7.99607 9.45789L7.81321 9.23846L7.9329 9.21851C8.10911 9.19192 9.69164 9.20189 10.0673 9.23514Z" fill="white"/>
            </svg>
        ]]
    ),

    ['icon-crosshair'] = svgCreate(17, 16,
        [[
            <svg width="17" height="16" viewBox="0 0 17 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8.79299 0.862919C8.9262 0.922123 9.05053 1.03757 9.12157 1.1767C9.16893 1.26847 9.17782 1.35135 9.17782 1.6977V2.1062L9.51528 2.15653C11.543 2.46143 13.3191 3.76984 14.225 5.62589C14.521 6.23273 14.6927 6.78037 14.7933 7.43457L14.8466 7.77203H15.2551C15.5985 7.77203 15.6814 7.78091 15.7731 7.82828C16.2527 8.07397 16.2527 8.71338 15.7731 8.95908C15.6814 9.00644 15.5985 9.01532 15.2522 9.01532H14.8436L14.7933 9.35278C14.595 10.679 13.9822 11.8808 13.0113 12.8488C12.0315 13.8286 10.7793 14.4591 9.45015 14.6397L9.17782 14.6782V15.0897C9.17782 15.436 9.16893 15.5189 9.12157 15.6107C8.91732 16.0103 8.40224 16.0932 8.10622 15.7764C7.96413 15.6225 7.93453 15.507 7.93453 15.0719V14.6752L7.74804 14.6545C7.23592 14.5983 6.42187 14.3644 5.90383 14.1217C3.97378 13.2218 2.5884 11.3539 2.31014 9.29062L2.27166 9.01532H1.86907C1.54049 9.01532 1.44577 9.00348 1.34808 8.95908C0.862605 8.7341 0.856685 8.07693 1.3392 7.82828C1.43096 7.78091 1.51385 7.77203 1.86019 7.77203H2.27166L2.31014 7.49969C2.49072 6.1676 3.11828 4.9184 4.10107 3.93857C4.82632 3.21036 5.63445 2.71305 6.58764 2.39926C6.96358 2.27494 7.42537 2.16837 7.76284 2.12989L7.93453 2.11213V1.70658C7.93453 1.37799 7.94637 1.28327 7.99077 1.18558C8.13286 0.88068 8.49401 0.73267 8.79299 0.862919ZM9.15117 3.51526C9.06829 3.79648 8.84627 3.96225 8.55321 3.96225C8.26607 3.96225 8.04702 3.79352 7.95821 3.50046L7.92269 3.38797L7.77468 3.40573C7.69179 3.41757 7.4757 3.46494 7.29513 3.50934C5.73214 3.90897 4.45629 5.04569 3.84649 6.57907C3.7488 6.82773 3.60079 7.37537 3.56823 7.61218L3.55047 7.76019L3.67776 7.79868C3.95898 7.88156 4.12771 8.10654 4.12771 8.39368C4.12771 8.68082 3.95898 8.90579 3.67776 8.98868L3.55047 9.02716L3.56823 9.17517C3.60079 9.41199 3.7488 9.95962 3.84649 10.2083C4.37637 11.5433 5.40652 12.5735 6.74157 13.1034C6.99023 13.201 7.53786 13.3491 7.77172 13.3816L7.91973 13.3994L7.97005 13.2543C8.07366 12.9672 8.26903 12.8221 8.55617 12.8221C8.84627 12.8221 9.06829 12.9909 9.15117 13.2721L9.18966 13.4023L9.32287 13.3816C9.5656 13.3491 10.0688 13.2158 10.3323 13.1152C11.6733 12.6031 12.7301 11.5552 13.2659 10.2083C13.3635 9.95962 13.5116 9.41199 13.5441 9.17517L13.5619 9.02716L13.4346 8.98868C13.257 8.93539 13.1593 8.85547 13.0646 8.69562C12.8603 8.34927 13.0409 7.91708 13.4346 7.79868L13.5619 7.76019L13.5441 7.61218C13.5116 7.37537 13.3635 6.83069 13.2659 6.57907C12.9935 5.89822 12.6205 5.33283 12.1055 4.81479C11.4216 4.13394 10.5277 3.65143 9.58336 3.4531C9.18966 3.37021 9.19262 3.37021 9.15117 3.51526Z" fill="white"/>
                <path d="M8.92645 5.25581C9.40009 5.31798 9.92108 5.51039 10.3237 5.77977C10.5368 5.92186 10.892 6.2534 11.0578 6.4695C11.487 7.03193 11.7031 7.68022 11.7031 8.39363C11.7031 9.29057 11.3686 10.0661 10.7144 10.6878C9.80859 11.5462 8.44098 11.789 7.31018 11.2917C6.24451 10.8269 5.54294 9.85893 5.41565 8.68077C5.35645 8.13313 5.46302 7.56181 5.72647 7.01713C6.04322 6.36885 6.51685 5.8893 7.15329 5.56959C7.68317 5.30614 8.36402 5.18477 8.92645 5.25581Z" fill="white"/>
            </svg>            
        ]]
    ),

    ['border-select'] = svgCreate(71*2, 29*2,
        [[
            <svg width="71" height="29" viewBox="0 0 71 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="0.878906" y="0.661621" width="69.1425" height="27.2456" rx="13.6228" stroke="white"/>
            </svg>
        ]]
    ),

    ['border-check'] = svgCreate(71*2, 29*2,
        [[
            <svg width="71" height="29" viewBox="0 0 71 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="0.878906" y="1.15283" width="69.1425" height="27.2456" rx="13.6228" fill="white" fill-opacity="0.38" stroke="white"/>
            </svg>
        ]]
    ),

    ['circle-check'] = svgCreate(21, 22,
        [[
            <svg width="21" height="22" viewBox="0 0 21 22" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="10.5026" cy="11.0212" r="10.0573" fill="#DBDBDB"/>
            </svg>
        ]]
    ),

    ['border-bar'] = svgCreate(163*2, 29*2,
        [[
            <svg width="163" height="29" viewBox="0 0 163 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="0.595703" y="0.657715" width="161.425" height="27.2456" rx="13.6228" stroke="white"/>
            </svg>
        ]]
    ),

    ['border-bar-2'] = svgCreate(118/2, 7/2,
        [[
            <svg width="118" height="7" viewBox="0 0 118 7" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="0.515625" y="0.0932617" width="116.826" height="5.93405" rx="2.96703" fill="white"/>
            </svg>
        ]]
    ),

    ['border-visualização'] = svgCreate(147, 71,
        [[
            <svg width="147" height="71" viewBox="0 0 147 71" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="0.628906" y="1.0957" width="145.724" height="69.2436" rx="9.5" stroke="white"/>
            </svg>
        ]]
    ),

    ['border-color'] = svgCreate(157, 98,
        [[
            <svg width="157" height="98" viewBox="0 0 157 98" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="1.27539" y="1.0957" width="154.315" height="96.1262" rx="9.5" stroke="white"/>
            </svg>            
        ]]
    ),

    ['border-crosshairs'] = svgCreate(212, 30,
        [[
            <svg width="212" height="30" viewBox="0 0 212 30" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="1.05273" y="1.4834" width="209.538" height="27.2456" rx="13.6228" stroke="white"/>
            </svg>
        ]]
    ),

    ['arrow'] = svgCreate(12, 11,
        [[
            <svg width="12" height="11" viewBox="0 0 12 11" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M4.18889 9.09192C4.95869 10.4253 6.88319 10.4253 7.653 9.09192L11.1045 3.11382C11.8743 1.78049 10.912 0.113822 9.3724 0.113822H2.46949C0.929888 0.113822 -0.0323622 1.78049 0.737438 3.11382L4.18889 9.09192Z" fill="white"/>
            </svg>
        ]]
    ),

    ['password'] = svgCreate(18, 19,
        [[
            <svg width="18" height="19" viewBox="0 0 18 19" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M4.56831 10.3807C4.67711 10.4895 4.89471 10.7071 5.11232 10.7071C5.32992 10.8159 5.54752 10.8159 5.76513 10.8159C5.98273 10.8159 6.20034 10.8159 6.41794 10.7071C6.63554 10.5983 6.85315 10.4895 6.96195 10.3807L10.226 7.11666C10.5524 6.79026 10.77 6.35505 10.77 5.91984C10.77 5.48463 10.5524 5.04942 10.226 4.72302L6.30914 0.806142C6.20034 0.588538 5.98273 0.479736 5.76513 0.479736H1.19544C0.760234 0.479736 0.325026 0.914944 0.325026 1.35015V5.91984C0.325026 6.13744 0.433828 6.35505 0.54263 6.46385L4.56831 10.3807ZM2.06586 2.22057H5.43872L9.13799 5.91984V6.02864L5.87393 9.2927L6.41794 9.83671L5.65633 9.2927L2.06586 5.59343V2.22057ZM0.107422 18.7585H9.8996V17.1264H0.107422V18.7585ZM0.107422 12.7744V14.4064H17.5157V12.7744H0.107422Z" fill="#FCA555"/>
            </svg>
        ]]
    ),

    ['male'] = svgCreate(30, 31,
        [[
            <svg width="30" height="31" viewBox="0 0 30 31" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16.2501 2.55933V4.24552H20.2156H24.1868L21.2505 7.18182L18.3142 10.1181L17.7328 9.74018C16.4711 8.90872 15.0581 8.35053 13.4301 8.04236C12.7033 7.90863 10.895 7.87956 10.0461 7.99003C3.87694 8.80406 -0.49553 14.4092 0.231277 20.59C0.673176 24.381 2.98733 27.6894 6.40042 29.4163C7.45865 29.9512 8.51107 30.2885 9.76699 30.5094C10.6333 30.6606 12.5579 30.6432 13.4592 30.4804C18.4015 29.5849 22.146 25.6776 22.7972 20.7411C22.9367 19.6887 22.8844 18.02 22.6751 17.0373C22.3727 15.5837 21.8087 14.2115 21.047 13.0544L20.6691 12.473L23.6054 9.53668L26.5417 6.60038V10.5717V14.5371H28.2279H29.9141V7.70512V0.873135H23.0821H16.2501V2.55933ZM12.9649 11.7752C14.5697 12.1125 15.7384 12.7404 16.8897 13.8975C17.82 14.8278 18.3608 15.6767 18.7445 16.8396C19.0469 17.7467 19.1283 18.2526 19.1225 19.2759C19.1225 20.2876 19.0062 20.997 18.7096 21.8284C17.913 24.0438 16.0524 25.8288 13.8139 26.5382C12.6975 26.8928 11.2439 26.9742 10.1159 26.7591C6.69114 26.0846 4.20837 23.3169 3.92927 19.8573C3.59785 15.7988 6.53997 12.2113 10.6101 11.688C11.1566 11.6124 12.4242 11.6648 12.9649 11.7752Z" fill="white"/>
            </svg>
        ]]
    ),
  
    ['female'] = svgCreate(24, 36,
        [[
            <svg width="24" height="36" viewBox="0 0 24 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11.2698 0.0767937C9.79661 0.249706 8.89055 0.464115 7.85308 0.872189C2.76254 2.8918 -0.259966 8.1345 0.55618 13.5501C1.07492 16.9945 3.10145 20.024 6.11704 21.8568C7.31359 22.5761 8.90438 23.171 10.2185 23.3715L10.7511 23.4545L10.7718 25.4396L10.7857 27.4246H9.25021C7.90149 27.4246 7.67325 27.4454 7.43117 27.556C6.55278 27.9641 6.37295 29.0431 7.07151 29.7624C7.42426 30.1289 7.777 30.1912 9.37471 30.1912H10.7788L10.7995 32.3491C10.8203 34.4863 10.8203 34.514 10.9862 34.7768C11.0762 34.9221 11.2767 35.1227 11.4289 35.2264C11.8301 35.4961 12.5079 35.4961 12.909 35.2264C13.0612 35.1227 13.2618 34.9221 13.3517 34.7768C13.5177 34.514 13.5177 34.4863 13.5384 32.3491L13.5592 30.1912H14.9632C16.5609 30.1912 16.9137 30.1289 17.2664 29.7624C17.965 29.0431 17.7852 27.9641 16.9068 27.556C16.6647 27.4454 16.4364 27.4246 15.0877 27.4246H13.5523L13.5661 25.4396L13.5868 23.4545L14.1194 23.3715C15.4336 23.171 17.0243 22.5761 18.2209 21.8568C25.0267 17.7277 25.8844 8.23825 19.9293 2.9748C18.2831 1.52234 16.2635 0.57478 14.0364 0.20129C13.4416 0.0975418 11.7125 0.0214615 11.2698 0.0767937ZM14.0226 3.00938C15.807 3.38979 17.1903 4.15061 18.4976 5.46474C20.282 7.2492 21.1258 9.26881 21.1189 11.7933C21.1189 12.9138 21.0221 13.5778 20.7316 14.4908C19.6595 17.8383 16.8307 20.2107 13.3448 20.681C12.4318 20.8055 11.9061 20.8055 10.9932 20.681C7.50725 20.2107 4.67841 17.8383 3.60635 14.4908C3.31586 13.5778 3.21903 12.9138 3.21903 11.7933C3.21211 10.5968 3.32969 9.87746 3.66168 8.90915C4.13892 7.52585 4.77524 6.52988 5.84038 5.46474C7.32051 3.97769 8.95972 3.16846 11.0692 2.87106C11.754 2.77422 13.2825 2.84339 14.0226 3.00938Z" fill="white"/>
            </svg>            
        ]]
    ),

}

config.optionsInicio = {

    {
        title = 'Renderização do mapa',
        style = 'bar',
    },
    
    {
        title = 'Renderização de neblina',
        style = 'bar',
    },
    
    {
        title = 'Tamanho do sol/lua',
        style = 'bar',
    },
    
    {
        title = 'Estilo de interface [HUD]',
        style = 'select',
        itens = {'Estilo 3', 'Estilo 2', 'Estilo 1'},
    },
    
    {
        title = 'Limite de Frames [FPS]',
        style = 'select',
        itens = {30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100},
    },
    
    {
        title = 'Vegetação do ambiente',
        style = 'check',
    },
    
    {
        title = 'Som de armas 3D',
        style = 'check',
    },    
    
    {
        title = 'Ruas',
        style = 'check',
    },

    {
        title = 'Plotagem',
        style = 'check',
    },

    {
        title = 'FXAA (Anti-aliasing)',
        style = 'check',
    },

    {
        title = 'Chat',
        style = 'check',
    },

    {
        title = 'Flocos de neve',
        style = 'check',
    },

    {
        title = 'Céu Realista',
        style = 'check',
    },

    {
        title = 'Àgua Realista',
        style = 'check',
    },

}


config.optionsCrosshair = {

    {
        title = 'Escolha da mira',
        style = 'crosshair',
        ammount = 9,
    },
    
    {
        title = 'Tamanho da mira',
        style = 'bar',
    },
    
    {
        title = 'Opacidade da mira',
        style = 'bar',
    },

}

cache = {}

function executeFunction (title, value, tabela)
    if title == 'Limite de Frames [FPS]' then
        setFPSLimit(tabela.itens[value])
        config.notify('client', _, 'Você alterou o limite de FPS para '..tabela.itens[value]..'.', 'success')
    elseif title == 'Estilo de interface [HUD]' then
        setElementData(localPlayer, 'HudType', tabela.itens[value])
        config.notify('client', _, 'Você alterou a hud para '..tabela.itens[value]..'.', 'success')
    elseif title == 'Renderização do mapa' then
        setFarClipDistance(1500 * (value / 100))
    elseif title == 'Renderização de neblina' then
        setFogDistance((500/30) * (value / 100))
    elseif title == 'Tamanho do sol/lua' then
        setSunSize(value)
        setMoonSize(value)
    elseif title == 'Vegetação do ambiente' then
        if value then
            for i = 615, 904 do
                restoreWorldModel (i, 999999999999999999999, 0, 0, 0)
            end
        else
            for i = 615, 904 do
                removeWorldModel (i, 999999999999999999999, 0, 0, 0)
            end
        end	
    elseif title == 'Som de armas 3D' then
        exports['[BAR]SomArmas']:loadMod(value)
    elseif title == 'Ruas' then
        triggerEvent('loadRuas', localPlayer, value)
    elseif title == 'Plotagem' then
        exports['[BAR]Plotagem']:changeState(value)
    elseif title == 'FXAA (Anti-aliasing)' then
        if tonumber(dxGetStatus().VideoCardPSVersion) < 3 then 
            config.notify('client', _, "FXAA não é suportado para Model 3!", "error")
            return 
        end
        triggerEvent("switchFxaa", localPlayer, value)
    elseif title == 'Chat' then
        showChat(value)
    elseif title == 'Flocos de neve' then
        if value then
            triggerEvent("JOAO.createSnowFlakes", localPlayer)
        else
            triggerEvent("JOAO.removeSnowFlakes", localPlayer)
        end
    elseif title == 'Céu Realista' then
        triggerEvent("switchSkyAlt", localPlayer, value)
    elseif title == 'Àgua Realista' then
        if getVersion().sortable < "1.3.0" then
            config.notify('client', _, "O recurso não é compatível com este cliente.", "error")
            return
        end
        exports["shader_water"]:manageWater(value)
    end
end

function render ()

    cursor.state = isCursorShowing ();
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;
    end
    local alpha = interpolateBetween(effect[1], 0, 0, effect[2], 0, 0, ((getTickCount()-effect[3])/effect[4]), 'Linear')
    animationY = interpolateBetween(animation[1], 0, 0, animation[2], 0, 0, ((getTickCount()-animation[3])/animation[4]), 'InOutQuad')

    dxDrawRounded(0, 0, 347.04, 413.38, 4.48, tocolor(47, 47, 47, alpha * 0.98))
    dxDrawImage(18.56, 17.95, 30.82, 31.56, svg['icon'], 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText('Configurações', 55.23, 17.23, 82, 19, tocolor(255, 255, 255, alpha), 1, getFont('bold', 14), 'left', 'center')
    dxDrawText(select == 'infos' and 'Da sua conta.' or 'Personalize o seu jogo da sua maneira.', 55.23, 34.23, 82, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 9), 'left', 'center')

    dxDrawImage(245.54, 15.51, 41.93, 23.43, svg['border'], 0, 0, 0, (isMouseInPosition(245.54, 15.51, 41.93, 23.43) or select == 'infos') and tocolor(14, 158, 247, alpha) or tocolor(137, 137, 137, alpha))
    dxDrawImage(258.89, 19.62, 15.21, 15.2, svg['icon-infos'], 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawImage(290.59, 15.51, 41.93, 23.43, svg['border'], 0, 0, 0, (isMouseInPosition(290.59, 15.51, 41.93, 23.43) or select == 'crosshair') and tocolor(14, 158, 247, alpha) or tocolor(137, 137, 137, alpha))
    dxDrawImage(303.98, 19.64, 15.15, 15.15, svg['icon-crosshair'], 0, 0, 0, tocolor(255, 255, 255, alpha))

    if select == 'infos' or select == 'crosshair' then
        dxDrawText('[BACKSPACE] PARA RETORNAR', 0, 413, 347.04, 30.38, tocolor(255, 255, 255, alpha), 1, getFont('regular', 12), 'center', 'center')
    end

    if select == 'inicio' then
        linha = 0
        for i, v in ipairs(config.optionsInicio) do
            if (i > proxPag and linha < 7) then
                linha = linha + 1
                local py = 71.98+((28.35+21.76)*(linha-1))
                if linha ~= 1 then
                    dxDrawRectangle(18, py-11.61, 313.96, 1, tocolor(59, 59, 65, alpha))
                end
                dxDrawText(v.title, 18.56, py+6.9, 0, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
                if v.style == 'select' then
                    if not cache[v.title] then
                        cache[v.title] = #v.itens
                    end
                    dxDrawImage(262.38, py, 70.14, 28.25, svg['border-select'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
                    local text = v.itens[cache[v.title]]
                    if v.title == 'Limite de Frames [FPS]' then
                        text = text..' FPS'
                    end
                    dxDrawText(text, 262.38, py, 70.14, 28.25, isMouseInPosition(262.38, py, 70.14, 28.25) and tocolor(14, 158, 247, alpha) or tocolor(221, 221, 221, alpha), 1, getFont('regular', 11), 'center', 'center')
                elseif v.style == 'check' then
                    if not cache[v.title] then
                        cache[v.title] = false
                    end
                    dxDrawImage(262.38, py, 70.14, 28.25, svg['border-check'], 0, 0, 0, cache[v.title] and tocolor(14, 158, 247, alpha) or tocolor(255, 255, 255, alpha*0.1))
                    if not cache[v.title] then
                        dxDrawImage(270.42, py+4.07, 20.11, 20.11, svg['circle-check'], 0, 0, 0, tocolor(219, 219, 219, alpha))
                    else
                        dxDrawImage(304.45, py+4.07, 20.11, 20.11, svg['circle-check'], 0, 0, 0, tocolor(219, 219, 219, alpha))
                    end
                elseif v.style == 'bar' then
                    if not cache[v.title] then
                        cache[v.title] = 50
                    end
                    dxDrawImage(170.1, py, 162.43, 28.25, svg['border-bar'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
                    dxDrawImage(179.52, py+10.94, 116.83, 5.93, svg['border-bar-2'], 0, 0, 0, tocolor(59, 59, 65, alpha))
                    local width = 116.83 / 100 * cache[v.title]
                    dxDrawImageSection(179.52, py+10.94, width, 5.93, 0, 0, width, 5.93, svg['border-bar-2'], 0, 0, 0, tocolor(14, 158, 247, alpha))
                    dxDrawImage(179.52+width-(8.63/2), py+9.81, 8.63, 8.63, svg['circle-check'], 0, 0, 0, tocolor(217, 217, 217, alpha))
                    dxDrawText(math.floor(cache[v.title])..'%', 306.69, py+6.9, 17.04, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'right', 'center')
                    if (moving == v.title) then 
                        local cx, cy = getCursorPosition() 
                        local mx, my = (cx * screenW), (cy * screenH)
                        local posInicio = respX(170.1)
                        local posFinal = respX(170.1)+respC(162.43)
                        if (mx > posInicio) and (mx < (posFinal)) then 
                            local w = (mx - (posInicio)) 
                            cache[v.title] = (w / respC(162.43)) * 100
                        elseif (mx > posInicio) and (mx > (posFinal)) then 
                            cache[v.title] = 100
                        else 
                            cache[v.title] = 0
                        end
                    end
                end
            end
        end
    elseif select == 'infos' then
        dxDrawRectangle(18, 71.98, 313.96, 1, tocolor(59, 59, 65, alpha))
        dxDrawRectangle(69.02, 163.58, 266.15, 1, tocolor(59, 59, 65, alpha))

        dxDrawImage(16.54, 88.1, 49.59, 46.59, ':[BAR]Prefeitura/files/avatars/'..(getElementData(localPlayer, 'Avatar') or 0)..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Nome', 85.58, 91.41, 0, 17, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
        dxDrawText(getPlayerName(localPlayer), 85.58, 108.41, 0, 17, tocolor(14, 158, 247, alpha), 1, getFont('medium', 12), 'left', 'center')
        
        dxDrawText('Gênero', 21.69, 155.08, 0, 17, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
        
        dxDrawRounded(16.54, 178.89, 129.27, 65.7, 2, (isMouseInPosition(16.54, 178.89, 129.27, 65.7) or generoSelect == 'male') and tocolor(68, 96, 114, alpha) or tocolor(61, 61, 61, alpha))
        dxDrawText('Masculino', 30.89, 203.24, 0, 17, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'left', 'center')
        dxDrawImage(100.58, 196.87, 29.76, 29.74, svg['male'], 0, 0, 0, (isMouseInPosition(16.54, 178.89, 129.27, 65.7) or generoSelect == 'male') and tocolor(102, 145, 255, alpha) or tocolor(80, 80, 80, alpha))

        dxDrawRounded(150.15, 178.89, 129.27, 65.7, 2, (isMouseInPosition(150.15, 178.89, 129.27, 65.7) or generoSelect == 'female') and tocolor(107, 68, 114, alpha) or tocolor(61, 61, 61, alpha))
        dxDrawText('Feminino', 165.78, 203.24, 0, 17, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'left', 'center')
        dxDrawImage(237.86, 194.06, 23.48, 35.37, svg['female'], 0, 0, 0, (isMouseInPosition(150.15, 178.89, 129.27, 65.7) or generoSelect == 'female') and tocolor(252, 102, 255, alpha) or tocolor(80, 80, 80, alpha))

        dxDrawText('Clique sobre o gênero que deseja atualizar.', 16.54, 251.05, 0, 17, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
        dxDrawText(formatNumber(config.priceGenero)..' aPoints', 16.54, 274.5, 0,  32, tocolor(14, 158, 247, alpha), 1, getFont('bold', 25), 'left', 'center')
        dxDrawImage(16.54, 321.48, 17.41, 18.28, svg['password'], 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Para trocar sua senha é preciso autenticar sua senha atual antes da troca.', 42.56, 318.62, 240, 24, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center', false, true)

        dxDrawRounded(16.54, 363.06, 155.54, 36.31, 1, isMouseInPosition(16.54, 363.06, 155.54, 36.31) and tocolor(14, 158, 247, alpha) or tocolor(59, 59, 59, alpha))
        dxDrawText('ALTERAR DEFINIÇÃO', 16.54, 363.06, 155.54, 36.31, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'center', 'center')
        
        dxDrawRounded(174.96, 363.06, 160.21, 36.31, 1, isMouseInPosition(174.96, 363.06, 160.21, 36.31) and tocolor(14, 158, 247, alpha) or tocolor(59, 59, 59, alpha))
        dxDrawText('ALTERAR SENHA', 174.96, 363.06, 160.21, 36.31, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'center', 'center')

        if alterPassword then
            dxDrawRounded(0, 0, 347.04, 413.38, 4.48, tocolor(47, 47, 47, alpha * 0.7))
            dxDrawRounded(63.43, 123, 220.95, 168.82, 9, tocolor(65, 65, 65, alpha))
            dxDrawText('ESCOLHA A NOVA SENHA', 77.08, 138.01, 105.93, 14, tocolor(221, 221, 221, alpha), 1, getFont('medium', 12), 'left', 'center')
            dxDrawText('Caso você altere sua senha e esqueça\ncontate a administração', 77.08, 158.29, 105.93, 28, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')

            dxDrawRounded(77.08, 192.57, 193.65, 31.03, 1, tocolor(62, 62, 62, alpha))
            dxDrawText(getEditboxValue('NOVA SENHA', true), 77.08, 192.57, 193.65, 31.03, tocolor(129, 129, 129, alpha), 1, getFont('regular', 12), 'center', 'center')

            dxDrawRounded(77.08, 237.79, 193.65, 31.03, 1, isMouseInPosition(77.08, 237.79, 193.65, 31.03) and tocolor(14, 158, 247, alpha) or tocolor(59, 59, 59, alpha))
            dxDrawText('CONFIRMAR', 77.08, 237.79, 193.65, 31.03, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'center', 'center')
        end

    elseif select == 'crosshair' then
        linha = 0
        for i, v in ipairs(config.optionsCrosshair) do
            linha = linha + 1
            local py = 71.98+((28.35+21.76)*(linha-1))
            if linha ~= 1 then
                dxDrawRectangle(18, py-11.61, 313.96, 1, tocolor(59, 59, 65, alpha))
            end
            dxDrawText(v.title, 18.56, py+6.9, 0, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
            if v.style == 'bar' then
                if not cache[v.title] then
                    cache[v.title] = 100
                end
                dxDrawImage(170.1, py, 162.43, 28.25, svg['border-bar'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
                dxDrawImage(179.52, py+10.94, 116.83, 5.93, svg['border-bar-2'], 0, 0, 0, tocolor(59, 59, 65, alpha))
                local width = 116.83 / 100 * cache[v.title]
                dxDrawImageSection(179.52, py+10.94, width, 5.93, 0, 0, width, 5.93, svg['border-bar-2'], 0, 0, 0, tocolor(14, 158, 247, alpha))
                dxDrawImage(179.52+width-8.63, py+9.81, 8.63, 8.63, svg['circle-check'], 0, 0, 0, tocolor(217, 217, 217, alpha))
                dxDrawText(math.floor(cache[v.title])..'%', 306.69, py+6.9, 17.04, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'right', 'center')
                if (moving == v.title) then 
                    local cx, cy = getCursorPosition() 
                    local mx, my = (cx * screenW), (cy * screenH)
                    local posInicio = respX(170.1)
                    local posFinal = respX(170.1)+respC(162.43)
                    if (mx > posInicio) and (mx < (posFinal)) then 
                        local w = (mx - (posInicio)) 
                        cache[v.title] = (w / respC(162.43)) * 100
                    elseif (mx > posInicio) and (mx > (posFinal)) then 
                        cache[v.title] = 100
                    else 
                        cache[v.title] = 0
                    end
                end
            elseif v.style == 'crosshair' then
                dxDrawImage(121.98, py, 210.54, 28.25, svg['border-crosshairs'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
                dxDrawImage(130.37, py+8, 12, 12, svg['arrow'], 90, 0, 0, isMouseInPosition(130.37, py+8, 12, 12) and tocolor(14, 158, 247, alpha) or tocolor(217, 217, 217, alpha))
                dxDrawImage(309.14, py+8, 12, 12, svg['arrow'], -90, 0, 0, isMouseInPosition(309.14, py+8, 12, 12) and tocolor(14, 158, 247, alpha) or tocolor(217, 217, 217, alpha))
                local linhaMiras = 0
                for i=1, v.ammount do
					if (i > proxPagMiras and linhaMiras < 7) then 
                        linhaMiras = linhaMiras + 1
                        local px = 152.45 + (22 * (linhaMiras - 1))
                        dxDrawImage(px, 80, 12, 12, 'assets/images/miras/'..i..'.png', 0, 0, 0, (isMouseInPosition(px, 80, 12, 12) or selectMira == i) and tocolor(14, 158, 247, alpha) or tocolor(255, 255, 255, alpha))
                    end
                end
            end
        end
        dxDrawRectangle(18, 210.38, 313.96, 1, tocolor(59, 59, 65, alpha))
        dxDrawText('Pré visualização da mira', 18.56, 221.99, 0, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
        dxDrawImage(18.56, 244.6, 146.72, 70.24, svg['border-visualização'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
        local size = math.floor(cache['Tamanho da mira'])
        local size = 37.7 / 100 * size
        dxDrawImage(18.56+(146.72/2)-size/2, 244.6+(70.24/2)-size/2, size, size, 'assets/images/miras/'..selectMira..'.png', 0, 0, 0, tocolor(selectedColor[1], selectedColor[2], selectedColor[3], alpha / 100 * math.floor(cache['Opacidade da mira'])))
        dxDrawText('Selecione a cor', 177.21, 221.99, 0, 14, tocolor(221, 221, 221, alpha), 1, getFont('regular', 10), 'left', 'center')
        dxDrawImage(177.21, 244.6, 155.32, 97.13, svg['border-color'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.1))
        _dxDrawImage(colorPickerX, colorPickerY, colorPickerW, colorPickerH, colorPickerTexture, 0, 0, 0, tocolor(255, 255, 255, alpha))
        _dxDrawImage(colorPickerX+cursorLastPositionX, colorPickerY+cursorLastPositionY, 10, 10, svg['circle-check'], 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawRounded(310.21, 251.13, 17.52, 13.08, 1, tocolor(217, 217, 217, alpha))
        dxDrawRounded(310.21, 265.62, 17.52, 13.08, 1, tocolor(18, 18, 18, alpha))
        dxDrawRounded(310.21, 280.11, 17.52, 52.56, 1, tocolor(72, 72, 72, alpha))
        dxDrawRounded(18.56, 363.46, 313.96, 35.51, 1, isMouseInPosition(18.56, 363.46, 313.96, 35.51) and tocolor(14, 158, 247, alpha) or tocolor(59, 59, 59, alpha))
        dxDrawText('SALVAR PERSONALIZAÇÃO', 18.56, 363.46, 313.96, 35.51, tocolor(221, 221, 221, alpha), 1, getFont('regular', 12), 'center', 'center')
    end

end

-- mira

aimPositions = {
	['1920x1080'] = { normal = {1015, 431}; vehicle = {1015, 431} };
	['1680x1050'] = { normal = {888, 420}; vehicle = {888, 420} };
	['1600x1024'] = { normal = {845, 409}; vehicle = {845, 409} };
	['1600x900'] = { normal = {845, 360}; vehicle = {845, 360} };
	['1440x900'] = { normal = {760, 360}; vehicle = {760, 360} };
	['1366x768'] = { normal = {720, 307}; vehicle = {720, 307} };
	['1360x768'] = { normal = {717, 307}; vehicle = {717, 307} };
	['1280x1024'] = { normal = {675, 409}; vehicle = {675, 409} };
	['1280x960'] = { normal = {674, 384}; vehicle = {674, 384} };
	['1280x800'] = { normal = {675, 319}; vehicle = {675, 319} };
	['1280x768'] = { normal = {675, 307}; vehicle = {675, 307} };
	['1280x720'] = { normal = {675, 288}; vehicle = {675, 288} };
	['1176x664'] = { normal = {620, 265}; vehicle = {620, 265} };
	['1152x864'] = { normal = {607, 345}; vehicle = {607, 345} };
	['1024x768'] = { normal = {539, 307}; vehicle = {539, 307} };
	['800x600'] = { normal = {420, 240}; vehicle = {420, 240} };
	['720x576'] = { normal = {378, 230}; vehicle = {378, 230} };
	['720x480'] = { normal = {378, 192}; vehicle = {378, 192} };
	['640x480'] = { normal = {336, 192}; vehicle = {336, 192} };
}

local x, y = guiGetScreenSize ( )
addEventHandler('onClientRender', root, function()
    if crosshair then
        if (getPedWeapon(localPlayer) == 34) then 
            if not (isPlayerHudComponentVisible('crosshair')) then 
                setPlayerHudComponentVisible('crosshair', true) 
            end 
            return
        else
            if (isPlayerHudComponentVisible('crosshair')) then 
                setPlayerHudComponentVisible('crosshair', false) 
            end
        end
        if (isPedAiming(localPlayer)) then 
            if (aimPositions[x..'x'..y]) then 
                local aimPosition = aimPositions[x..'x'..y].normal 
                if (isPedInVehicle(localPlayer)) then 
                    aimPosition = aimPositions[x..'x'..y].vehicle  
                end
                local color = tocolor(crosshair.cor[1], crosshair.cor[2], crosshair.cor[3], crosshair.opacidade)
                _dxDrawImage(math.floor(aimPosition[1]), math.floor(aimPosition[2]), crosshair.tamanho, crosshair.tamanho, 'assets/images/miras/'..crosshair.mira..'.png', 0, 0, 0, color, false, true)
                if (isPlayerHudComponentVisible('crosshair')) then 
                    setPlayerHudComponentVisible('crosshair', false) 
                end 
            else
                if (isPedInVehicle (localPlayer)) then
                    local color = tocolor(crosshair.cor[1], crosshair.cor[2], crosshair.cor[3], crosshair.opacidade)
                    _dxDrawImage (x / 2 + (crosshair.tamanho/2), y / 2 - (crosshair.tamanho/2), crosshair.tamanho, crosshair.tamanho, 'assets/images/miras/'..crosshair.mira..'.png', 0, 0, 0, color, false, true)
                else
                    local ax, ay, az = getPedTargetStart (localPlayer)
                    screenWorld = {getScreenFromWorldPosition (ax, ay, az)}
                    local color = tocolor(crosshair.cor[1], crosshair.cor[2], crosshair.cor[3], crosshair.opacidade)
                    _dxDrawImage(math.floor(screenWorld[1]), math.floor(screenWorld[2]), crosshair.tamanho, crosshair.tamanho, 'assets/images/miras/'..crosshair.mira..'.png', 0, 0, 0, color, false, true)
                end
            end
        end
    else
        setPlayerHudComponentVisible('crosshair', true) 
    end
end)

function isPedAiming (thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end

function crosshairFunctions (type)
    if type == 'open' then
        proxPagMiras = 0
        selectMira = 1
        selectedColor = {255, 255, 255}
        colorPickerTexture = dxCreateTexture("assets/images/colorpicker.png")
        colorPickerX, colorPickerY, colorPickerW, colorPickerH = respX(183.77), respY(251.13), respC(125.03), respC(81.54)
        cursorLastPositionX, cursorLastPositionY = colorPickerW/2, colorPickerH/2
        addEventHandler("onClientCursorMove", root, onMouseMove)
    else
        if isElement(colorPickerTexture) then
            destroyElement(colorPickerTexture)
        end
        removeEventHandler("onClientCursorMove", root, onMouseMove)
    end
end

function onMouseMove (_, _, x, y)
    if movingColorPicker then
        local relativeX = (x - colorPickerX)
        local relativeY = (y - colorPickerY)
        local pixel = dxGetTexturePixels(colorPickerTexture)
        local r, g, b, a = dxGetPixelColor(pixel, relativeX, relativeY)
        if a and tonumber(a) and tonumber(a) >= 255 then
            cursorLastPositionX, cursorLastPositionY = relativeX-5, relativeY-5
            selectedColor = {r, g, b}
        end
    end
end

function click (button, state)
    if button == 'left' and state == 'down' then

        if alterPassword then
            selectEditbox = nil
            if isMouseInPosition(77.08, 192.57, 193.65, 31.03) then
                setEditboxEditing('NOVA SENHA')
            elseif isMouseInPosition(77.08, 237.79, 193.65, 31.03) then
                local senha = getEditboxValue('NOVA SENHA')
                triggerServerEvent('alterarSenha', localPlayer, senha)
                alterPassword = nil
            end
            return
        end

        if isMouseInPosition(245.54, 15.51, 41.93, 23.43) then
            select = 'infos'
            generoSelect = nil
            crosshairFunctions('close')
        elseif isMouseInPosition(290.59, 15.51, 41.93, 23.43) then
            select = 'crosshair'
            crosshairFunctions('open')
        end
        if select == 'inicio' then
            linha = 0
            for i, v in ipairs(config.optionsInicio) do
                if (i > proxPag and linha < 7) then
                    linha = linha + 1
                    local py = 71.98+((28.35+21.76)*(linha-1))
                    if v.style == 'select' then
                        if isMouseInPosition(262.38, py, 70.14, 28.25) then
                            if cache[v.title] == 1 then
                                cache[v.title] = #v.itens
                            else
                                cache[v.title] = cache[v.title] - 1
                            end
                            executeFunction(v.title, cache[v.title], v)
                        end
                    elseif v.style == 'check' then
                        if isMouseInPosition(262.38, py, 70.14, 28.25) then
                            if cache[v.title] == true then
                                cache[v.title] = false
                            else
                                cache[v.title] = true
                            end
                            executeFunction(v.title, cache[v.title], v)
                        end
                    elseif v.style == 'bar' then
                        if isMouseInPosition(179.52, py+10.94, 116.83, 5.93) then
                            moving = v.title
                        end
                    end
                end
            end
        elseif select == 'infos' then
            if isMouseInPosition(16.54, 178.89, 129.27, 65.7) then
                generoSelect = 'male'
            elseif isMouseInPosition(150.15, 178.89, 129.27, 65.7) then
                generoSelect = 'female'
            elseif isMouseInPosition(16.54, 363.06, 155.54, 36.31) then
                if generoSelect then
                    local gender = generoSelect == 'male' and 'Masculino' or 'Feminino'
                    triggerServerEvent('alterGender', localPlayer, gender, config.priceGenero)
                end
            elseif isMouseInPosition(174.96, 363.06, 160.21, 36.31) then
                alterPassword = true
                guiSetText(edit['NOVA SENHA'], '')
            end
        elseif select == 'crosshair' then
            linha = 0
            for i, v in ipairs(config.optionsCrosshair) do
                linha = linha + 1
                local py = 71.98+((28.35+21.76)*(linha-1))
                if v.style == 'bar' then
                    if isMouseInPosition(179.52, py+10.94, 116.83, 5.93) then
                        moving = v.title
                    end
                elseif v.style == 'crosshair' then
                    if isMouseInPosition(130.37, py+8, 12, 12) then
                        if (proxPagMiras > 0) then 
                            proxPagMiras = proxPagMiras - 1
                        end
                    elseif isMouseInPosition(309.14, py+8, 12, 12) then
                        proxPagMiras = proxPagMiras + 1
                        if (proxPagMiras > (v.ammount - 7)) then
                            proxPagMiras = (v.ammount - 7)
                        end
                    end
                    local linhaMiras = 0
                    for i=1, v.ammount do
                        if (i > proxPagMiras and linhaMiras < 7) then 
                            linhaMiras = linhaMiras + 1
                            local px = 152.45 + (22 * (linhaMiras - 1))
                            if isMouseInPosition(px, 80, 12, 12) then
                                selectMira = i
                            end
                        end
                    end
                end
            end
            if isMouseInPosition(colorPickerX, colorPickerY, colorPickerW, colorPickerH, true) then
                movingColorPicker = true
            elseif isMouseInPosition(310.21, 251.13, 17.52, 13.08) then
                selectedColor = {217, 217, 217}
            elseif isMouseInPosition(310.21, 265.62, 17.52, 13.08) then
                selectedColor = {18, 18, 18}
            elseif isMouseInPosition(310.21, 280.11, 17.52, 52.56) then
                selectedColor = {72, 72, 72}
            elseif isMouseInPosition(18.56, 363.46, 313.96, 35.51) then
                crosshair = {
                    mira = selectMira;
                    opacidade = 255 / 100 * math.floor(cache['Opacidade da mira']);
                    tamanho = 37.7 / 100 * math.floor(cache['Tamanho da mira']);
                    cor = {selectedColor[1], selectedColor[2], selectedColor[3]};
                }
            end
        end
    elseif button == 'left' and state == 'up' then
        rolandobarra = nil
        if moving then
            executeFunction(moving, cache[moving])
            moving = nil
        end
        movingColorPicker = false
    end
end

function key (button, press)
    if button == 'backspace' and press then
        if alterPassword and (selectEditbox == nil) then
            alterPassword = nil
            return
        end
        if select == 'infos' or select == 'crosshair' then
            select = 'inicio'
            crosshairFunctions('close')
        end
    elseif select == 'inicio' and (button == 'mouse_wheel_down' and press) then
        proxPag = proxPag + 1
        if (proxPag > (#config.optionsInicio - 7)) then
            proxPag = (#config.optionsInicio - 7)
        end
    elseif select == 'inicio' and (button == 'mouse_wheel_up' and press) then
        if (proxPag > 0) then
            proxPag = proxPag - 1
        end
    end
end

function panelState ()
    if not visible then
        createEditbox('NOVA SENHA', 15)
        select = 'inicio'
        proxPag = 0
        effect = {0, 255, getTickCount(), 150}
        animation = {150, 0, getTickCount(), 150}
        visible = true
        showCursor(true)
        addEventHandler('onClientRender', root, render)
        addEventHandler('onClientClick', root, click)
        addEventHandler('onClientKey', root, key)
    else
        if not closing then
            showCursor(false)
            removeEventHandler('onClientClick', root, click)
            removeEventHandler('onClientKey', root, key)
            closing = true
            effect = {255, 0, getTickCount(), 150}
            animation = {0, -150, getTickCount(), 150}
            setTimer(function ()
                closing = false
                visible = false
                removeEventHandler('onClientRender', root, render)
                crosshairFunctions('close')
                removeEditbox('all')
                alterPassword = false
            end, effect[4] + 50, 1)
        end
    end
end

function open ()
    panelState()
end
bindKey("f3", "down", open)
addCommandHandler('antlag', open)

function savePlayerData()
    if crosshair then
        cache['crosshair'] = crosshair
    end 
    local jsonData = toJSON(cache)
    local file = fileCreate("client_data.json")
    if file then
        fileWrite(file, jsonData)
        fileClose(file)
    end
end

function getTabelaConfig (titulo)
    for i, v in ipairs(config.optionsInicio) do
        if v.title == titulo then
            return v
        end
    end
    for i, v in ipairs(config.optionsCrosshair) do
        if v.title == titulo then
            return v
        end
    end
    return nil
end

function loadPlayerData ()
    local file = fileOpen("client_data.json")
    if file then
        local jsonData = fileRead(file, fileGetSize(file))
        cache = fromJSON(jsonData) or {}
        if cache['crosshair'] then
            crosshair = cache['crosshair']
        end
        for i, v in pairs(cache) do
            executeFunction(i, v, getTabelaConfig(i))
        end
        fileClose(file)
    end
end
loadPlayerData()

addEventHandler('onClientResourceStop', root, function (res)
    if res == getThisResource() then
        savePlayerData()
    end
end)

addEventHandler("onClientPlayerQuit", localPlayer, function()
    savePlayerData()
end)