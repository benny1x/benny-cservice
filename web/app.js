const mHud = document.getElementById('hud');
const mTitle = document.getElementById('hud-title');
const mCount = document.getElementById('hud-count');
const mLabel = document.getElementById('hud-label');
const mFraction = document.getElementById('hud-fraction');
const mProgressFill = document.getElementById('hud-progress-fill');
const mProgressText = document.getElementById('hud-progress-text');

let mVisible = false;

function mClampPercent(mValue) {
    return Math.max(0, Math.min(100, mValue));
}

function mHexToRgb(mHex) {
    const mClean = mHex.replace('#', '');

    if (mClean.length !== 6) {
        return null;
    }

    return {
        r: parseInt(mClean.slice(0, 2), 16),
        g: parseInt(mClean.slice(2, 4), 16),
        b: parseInt(mClean.slice(4, 6), 16),
    };
}

function mApplyTheme(mData) {
    const mRoot = document.documentElement;

    if (mData.m_accent) {
        mRoot.style.setProperty('--cs-accent', mData.m_accent);
    }

    if (mData.m_accent_dark) {
        mRoot.style.setProperty('--cs-accent-dark', mData.m_accent_dark);
    }
}

function mUpdateHud(mData) {
    mApplyTheme(mData);

    const mRemaining = Number(mData.m_tasks_remaining) || 0;
    const mTotal = Number(mData.m_total_tasks) || mRemaining;
    const mCompleted = Math.max(0, mTotal - mRemaining);
    const mPercent = mTotal > 0 ? mClampPercent((mCompleted / mTotal) * 100) : 0;

    mTitle.textContent = mData.m_title || 'Community Service';
    mLabel.textContent = mData.m_remaining_label || 'tasks remaining';
    mCount.textContent = String(mRemaining);
    mFraction.textContent = `${mCompleted} / ${mTotal}`;
    mProgressFill.style.width = `${mPercent}%`;
    mProgressText.textContent = `${Math.round(mPercent)}% complete`;
}

function mShowHud(mData) {
    mUpdateHud(mData || {});
    mHud.classList.remove('hud--hidden');
    mVisible = true;
}

function mHideHud() {
    mHud.classList.add('hud--hidden');
    mVisible = false;
}

window.addEventListener('message', (mEvent) => {
    const mAction = mEvent.data && mEvent.data.m_action;
    const mData = mEvent.data && mEvent.data.m_data;

    if (mAction === 'hud_show') {
        mShowHud(mData);
        return;
    }

    if (mAction === 'hud_update') {
        if (!mVisible) {
            mShowHud(mData);
            return;
        }

        mUpdateHud(mData || {});
        return;
    }

    if (mAction === 'hud_hide') {
        mHideHud();
    }
});
